import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:user_repository/src/user_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:user_repository/user_repository.dart';
import 'user_repository_test.mocks.dart';

@GenerateMocks([UserSecureStorage])
void main() {
  group('User Authentication Test: ', () {
    final userSecureStorage = MockUserSecureStorage();
    final keyValueStorage = KeyValueStorage();

    //Initialize _userSecureStorage
    final userRepository = UserRepository(
      secureStorage: userSecureStorage,
      noSqlStorage: keyValueStorage,
      remoteApi: FavQsApi(userTokenSupplier: () => Future.value()),
    );
    test(
        'When calling getToken after successful authentication, return '
        'authentication token', () async {
      //Add stubbing for fetching token from secure storage
      when(userSecureStorage.getToken()).thenAnswer((_) async => 'token');

      expect(await userRepository.getToken(), 'token');
    });
    test(
        'If you call the getToken for an unauthenticated user, throw '
        'UserAuthRequiredFavQsException', () async {
      final userErrorRepository = UserRepository(
        secureStorage: userSecureStorage,
        noSqlStorage: keyValueStorage,
        remoteApi: FavQsApi(
          userTokenSupplier: () => throw UserAuthRequiredFavQsException(),
        ),
      );
      //Stub the behaviour of throwing UserAuthRequiredFavQsException for
      // an unauthenticated user
      when(userSecureStorage.getToken())
          .thenThrow(UserAuthRequiredFavQsException());

      expect(
        () async => await userErrorRepository.getToken(),
        throwsA(isA<UserAuthRequiredFavQsException>()),
      );
    });
  });
}
