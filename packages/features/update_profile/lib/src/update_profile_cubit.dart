import 'package:domain_models/domain_models.dart';
import 'package:user_repository/user_repository.dart';
import 'package:form_fields/form_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit({
    required this.userRepository,
  }) : super(
          const UpdateProfileInProgress(),
        ) {
    _fetchUser();
  }

  final UserRepository userRepository;

  Future<void> _fetchUser() async {
    final user = await userRepository.getUser().first;
    if (user != null) {
      final newState = UpdateProfileLoaded(
        username: Username.unvalidated(user.username),
        email: Email.unvalidated(user.email),
      );

      emit(newState);
    }
  }

  void onEmailChanged(String newEmail) {
    final currentState = state as UpdateProfileLoaded;
    final previousEmail = currentState.email;
    final shouldValidate = previousEmail.isNotValid;

    final newEmailState = currentState.copyWith(
      email: shouldValidate
          ? Email.validated(
              newEmail,
              isAlreadyRegistered: newEmail == previousEmail.value
                  ? previousEmail.isAlreadyRegistered
                  : false,
            )
          : Email.unvalidated(newEmail),
    );

    emit(newEmailState);
  }

  void onEmailUnfocused() {
    final currentState = state as UpdateProfileLoaded;
    final newState = currentState.copyWith(
      email: Email.validated(
        currentState.email.value,
        isAlreadyRegistered: currentState.email.isAlreadyRegistered,
      ),
    );

    emit(newState);
  }

  void onUsernameChanged(String newUsername) {
    final currentState = state as UpdateProfileLoaded;
    final previousUsername = currentState.username;
    final shouldValidate = previousUsername.isNotValid;

    final newState = currentState.copyWith(
      username: shouldValidate
          ? Username.validated(newUsername,
              isAlreadyRegistered: newUsername == previousUsername.value
                  ? previousUsername.isAlreadyRegistered
                  : false)
          : Username.unvalidated(newUsername),
    );

    emit(newState);
  }

  void onUsernameUnfocused() {
    final currentState = state as UpdateProfileLoaded;
    final newState = currentState.copyWith(
      username: Username.validated(
        currentState.username.value,
        isAlreadyRegistered: currentState.username.isAlreadyRegistered,
      ),
    );
    emit(newState);
  }

  void onPasswordChanged(String newPassword) {
    final currentState = state as UpdateProfileLoaded;
    final previousPassword = currentState.password;
    final shouldValidate = previousPassword!.isNotValid;

    final newState = currentState.copyWith(
      password: shouldValidate
          ? OptionalPassword.validated(newPassword)
          : OptionalPassword.unvalidated(newPassword),
    );
    emit(newState);
  }

  void onPasswordUnfocused() {
    final currentState = state as UpdateProfileLoaded;
    final newState = currentState.copyWith(
      password: OptionalPassword.validated(
        currentState.password!.value,
      ),
    );
    emit(newState);
  }

  void onPasswordConfirmationChanged(newPassConf) {
    final currentState = state as UpdateProfileLoaded;
    final previousPasswordConfirmation = currentState.passwordConfirmation;
    final shouldValidate = previousPasswordConfirmation!.isNotValid;

    final newState = currentState.copyWith(
      passwordConfirmation: shouldValidate
          ? OptionalPasswordConfirmation.validated(
              newPassConf,
              password: currentState.password,
            )
          : OptionalPasswordConfirmation.unvalidated(newPassConf),
    );

    emit(newState);
  }

  void onPasswordConfirmationUnfocused() {
    final currentState = state as UpdateProfileLoaded;
    final newState = currentState.copyWith(
      passwordConfirmation: OptionalPasswordConfirmation.validated(
        currentState.passwordConfirmation!.value,
        password: currentState.password,
      ),
    );
    emit(newState);
  }

  void onSubmit() async {
    final currentState = state as UpdateProfileLoaded;
    final username = Username.validated(
      currentState.username.value,
      isAlreadyRegistered: currentState.username.isAlreadyRegistered,
    );
    final email = Email.validated(
      currentState.email.value,
      isAlreadyRegistered: currentState.email.isAlreadyRegistered,
    );
    final password = OptionalPassword.validated(
      currentState.password!.value,
    );
    final passwordConfirmation = OptionalPasswordConfirmation.validated(
      currentState.passwordConfirmation!.value,
      password: currentState.password,
    );

    final isFormValid = Formz.validate([
      username,
      email,
      password,
      passwordConfirmation,
    ]);

    final newState = currentState.copyWith(
      username: username,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      submissionStatus: isFormValid ? SubmissionStatus.inProgress : null,
    );

    emit(newState);

    if (isFormValid) {
      try {
        await userRepository.updateProfile(
          username.value,
          email.value,
          password.value,
        );
        final newState = currentState.copyWith(
          submissionStatus: SubmissionStatus.success,
        );
        emit(newState);
      } catch (error) {
        final newState = currentState.copyWith(
          submissionStatus: error is UsernameAlreadyTakenException &&
                  error is EmailAlreadyRegisteredException
              ? SubmissionStatus.error
              : SubmissionStatus.idle,
          username: error is UsernameAlreadyTakenException
              ? Username.validated(
                  username.value,
                  isAlreadyRegistered: true,
                )
              : null,
          email: error is EmailAlreadyRegisteredException
              ? Email.validated(
                  email.value,
                  isAlreadyRegistered: true,
                )
              : null,
        );
        emit(newState);
      }
    }
  }
}
