import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';
import 'package:domain_models/domain_models.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:user_repository/src/mappers/mappers.dart';
import 'package:user_repository/src/user_local_storage.dart';
import 'package:user_repository/src/user_secure_storage.dart';

class UserRepository {
  UserRepository({
    required KeyValueStorage noSqlStorage,
    required this.remoteApi,
    @visibleForTesting UserLocalStorage? localStorage,
    @visibleForTesting UserSecureStorage? secureStorage,
  })  : _localStorage =
            localStorage ?? UserLocalStorage(noSqlStorage: noSqlStorage),
        _secureStorage = secureStorage ?? const UserSecureStorage();

  final FavQsApi remoteApi;
  final UserLocalStorage _localStorage;
  final UserSecureStorage _secureStorage;
  final BehaviorSubject<User?> _userSubject = BehaviorSubject();
  final BehaviorSubject<DarkModePreference> _darkModePreferenceSubject =
      BehaviorSubject();

  Future<void> upsertDarkModePreference(DarkModePreference pref) async {
    await _localStorage.upsertDarkModePreference(pref.toCacheModel());
    _darkModePreferenceSubject.add(pref);
  }

  Stream<DarkModePreference> getDarkModePreference() async* {
    if (!_darkModePreferenceSubject.hasValue) {
      final storedPreference = await _localStorage.getDarkModePreference();
      _darkModePreferenceSubject.add(storedPreference?.toDomainModel() ??
          DarkModePreference.useSystemSettings);
    }

    yield* _darkModePreferenceSubject.stream;
  }

  Future<void> signIn(String email, String password) async {
    try {
      //Call the 'sign-in' endpoint on the server using the 
      // remoteApi property. If successful, a UserRM object
      // is returned and assigned to the apiUser variable.
      // UserRM class holds the recently signed-in user's 
      // token, email, and username.
      final apiUser = await remoteApi.signIn(email, password);

      await _secureStorage.upsertUserInfo(
        email: apiUser.email,
        username: apiUser.username,
        token: apiUser.token,
      );

      //Use a mapper function, toDomainModel(), to convert the apiUser
      // object from UserRM type to the User type.
      final domainUser = apiUser.toDomainModel();

      //Replaced- or added, if this is the first sign-in- a new value
      // to the BehaviourSubject.
      _userSubject.add(domainUser);
    } on InvalidCredentialsFavQsException catch (_) {
      //Capture any InvalidCredentialsFavQsExceptions and 
      // convert them to InvalidCredentialsExceptions since
      // the former is only known by packages importing fav_qs_api
      // internal package, which isn't the case for this UserRepository
      // class. The latter is from domain_models package, and therefore
      // known to all features, making it possible for them to handle
      // the exception properly.
      throw InvalidCredentialsException();
    }
  }

  //Expose the BehaviourSubject
  Stream<User?> getUser() async* {
    if (!_userSubject.hasValue) {
      final userInfo = await Future.wait([
        _secureStorage.getEmail(),
        _secureStorage.getUsername(),
      ]);

      final email = userInfo[0];
      final username = userInfo[1];

      if (email != null && username != null) {
        _userSubject.add(User(email: email, username: username));
      } else {
        _userSubject.add(
          null,
        );
      }
    }

    yield* _userSubject.stream;
  }

  //Provide the user token
  Future<String?> getToken() async {
    return _secureStorage.getToken();
  }

  Future<void> signUp(String username, String email, String password) async {
    try {
      final userToken = await remoteApi.signUp(username, email, password);

      await _secureStorage.upsertUserInfo(
        username: username,
        email: email,
        token: userToken,
      );

      _userSubject.add(
        User(email: email, username: username),
      );
    } catch (error) {
      if (error is UsernameAlreadyTakenFavQsException) {
        throw UsernameAlreadyTakenException();
      } else if (error is EmailAlreadyRegisteredFavQsException) {
        throw EmailAlreadyRegisteredException();
      }
      rethrow;
    }
  }

  Future<void> updateProfile(
    String username,
    String email,
    String newPassword,
  ) async {
    try {
      await remoteApi.updateProfile(username, email, newPassword);

      await _secureStorage.upsertUserInfo(
        username: username,
        email: email,
      );

      _userSubject.add(User(username: username, email: email));
    } on UsernameAlreadyTakenFavQsException catch (_) {
      throw UsernameAlreadyTakenException();
    }
  }

  Future<void> signOut() async {
    await remoteApi.signOut();
    await _secureStorage.deleteUserInfo();
    _userSubject.add(null);
  }

  Future<void> requestPasswordResetEmail(String email) async {
    await remoteApi.requestPasswordResetEmail(email);
  }
}

/*
BehaviourSubject class, from RxDart package, is a class that:
  --Holds a value, whose type is specified between the angle
    brackets <>.
  --Provides a Stream property that you can listen for any  
    changes to that value. When a given code starts to listen 
    to BehaviourSubject's stream, it immediately gets the latest
    value on that property-assuming that one has already been added.

This class is one of the most concise ways of managing app state.
*/