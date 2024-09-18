import 'package:domain_models/domain_models.dart';
import 'package:form_fields/form_fields.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({
    required this.userRepository,
  }) : super(const SignUpState());

  final UserRepository userRepository;

  void onEmailChanged(String newValue) {
    final previousEmail = state.email;
    final shouldValidate = previousEmail!.isNotValid;
    final newState = state.copyWith(
      email: shouldValidate
          ? Email.validated(newValue,
              isAlreadyRegistered: newValue == previousEmail.value
                  ? previousEmail.isAlreadyRegistered
                  : false)
          : Email.unvalidated(
              newValue,
            ),
    );

    emit(newState);
  }

  void onEmailUnfocused() {
    final newState = state.copyWith(
      email: Email.validated(
        state.email!.value,
        isAlreadyRegistered: state.email!.isAlreadyRegistered,
      ),
    );

    emit(newState);
  }

  void onUsernameChanged(String newUsername) {
    final previousUsername = state.username;
    final shouldValidate = previousUsername!.isNotValid;
    final newUsernameState = state.copyWith(
      username: shouldValidate
          ? Username.validated(newUsername,
              isAlreadyRegistered: newUsername == previousUsername.value
                  ? previousUsername.isAlreadyRegistered
                  : false)
          : Username.unvalidated(
              newUsername,
            ),
    );

    emit(newUsernameState);
  }

  void onUsernameUnfocused() {
    final newUsernameState = state.copyWith(
      username: Username.validated(
        state.username!.value,
        isAlreadyRegistered: state.username!.isAlreadyRegistered,
      ),
    );

    emit(newUsernameState);
  }

  void onPasswordChanged(String newPassword) {
    final previousPassword = state.password;
    final shouldValidate = previousPassword!.isNotValid;
    final newPasswordState = state.copyWith(
      password: shouldValidate
          ? Password.validated(newPassword)
          : Password.unvalidated(newPassword),
    );

    emit(newPasswordState);
  }

  void onPasswordUnfocused() {
    final newPasswordState = state.copyWith(
      password: Password.validated(
        state.password!.value,
      ),
    );

    emit(newPasswordState);
  }

  void onPasswordConfirmationChanged(String confirmPassword) {
    final previousPasswordConfirmation = state.passwordConfirmation;
    final shouldValidate = previousPasswordConfirmation!.isNotValid;

    final newPasswordConfirmState = state.copyWith(
        passwordConfirmation: shouldValidate
            ? PasswordConfirmation.validated(
                confirmPassword,
                password: state.password,
              )
            : PasswordConfirmation.unvalidated(
                confirmPassword,
              ));

    emit(newPasswordConfirmState);
  }

  void onPasswordConfirmationUnfocused() {
    final newPassConfirmState = state.copyWith(
      passwordConfirmation: PasswordConfirmation.validated(
        state.passwordConfirmation!.value,
        password: state.password,
      ),
    );

    emit(newPassConfirmState);
  }

  void onSubmit() async {
    final email = Email.validated(
      state.email!.value,
      isAlreadyRegistered: state.email!.isAlreadyRegistered,
    );

    final username = Username.validated(
      state.username!.value,
      isAlreadyRegistered: state.username!.isAlreadyRegistered,
    );

    final password = Password.validated(state.password!.value);

    final passwordConfirmation = PasswordConfirmation.validated(
        state.passwordConfirmation!.value,
        password: password);

    final isFormValid = Formz.validate([
      email,
      username,
      password,
      passwordConfirmation,
    ]);

    final newState = state.copyWith(
        email: email,
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
        submissionStatus: isFormValid ? SubmissionStatus.inProgress : null);

    emit(newState);

    if (isFormValid) {
      try {
        await userRepository.signUp(
          username.value,
          email.value,
          password.value,
        );
        final newState = state.copyWith(
          submissionStatus: SubmissionStatus.success,
        );
        emit(newState);
      } catch (error) {
        final newState = state.copyWith(
          submissionStatus: error is UsernameAlreadyTakenException &&
                  error is EmailAlreadyRegisteredException
              ? SubmissionStatus.error
              : SubmissionStatus.idle,
          username: error is UsernameAlreadyTakenException
              ? Username.validated(
                  username.value,
                  isAlreadyRegistered: true,
                )
              : state.username,
          email: error is EmailAlreadyRegisteredException
              ? Email.validated(
                  email.value,
                  isAlreadyRegistered: true,
                )
              : state.email,
        );

        emit(newState);
      }
    }
  }
}
