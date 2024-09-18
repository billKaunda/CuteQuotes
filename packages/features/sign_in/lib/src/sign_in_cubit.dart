import 'package:domain_models/domain_models.dart';
import 'package:user_repository/user_repository.dart';
import 'package:form_fields/form_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required this.userRepository,
  }) : super(
          const SignInState(),
        );

  final UserRepository userRepository;

  void onEmailChanged(String newEmail) {
    //Handle the user changing the value of the email field

    //Grab the cubit's state property and assign it a more meaningful
    // name within the function
    final previousScreenState = state;

    //Retrieve the previous state of the email field
    final previousEmailState = previousScreenState.email;

    //Recreate the state of the email field using the newEmail
    // parameter provided by the function
    final shouldValidate = previousEmailState.isNotValid;

    final newEmailState = shouldValidate
        ? Email.validated(newEmail)
        : Email.unvalidated(newEmail);

    final newScreenState = state.copyWith(email: newEmailState);

    emit(newScreenState);
  }

  void onEmailUnfocused() {
    //Handle the user taking the focus out of the email field

    final previousScreenState = state;
    final previousEmailScreenState = previousScreenState.email;
    final previousEmailValue = previousEmailScreenState.value;

    final newEmailState = Email.validated(previousEmailValue);
    emit(previousScreenState.copyWith(email: newEmailState));
  }

  void onPasswordChanged(String newValue) {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;
    final shouldValidate = previousPasswordState.isNotValid;

    final newPasswordState = shouldValidate
        ? Password.validated(newValue)
        : Password.unvalidated(newValue);

    final newScreenState = previousScreenState.copyWith(
      password: newPasswordState,
    );

    emit(newScreenState);
  }

  void onPasswordUnfocused() {
    final previousPasswordValue = state.password.value;

    final newPasswordState = Password.validated(previousPasswordValue);

    emit(state.copyWith(password: newPasswordState));
  }

  void onSubmit() async {
    final email = Email.validated(state.email.value);
    final password = Password.validated(state.password.value);

    final isFormValid = Formz.validate([email, password]);

    final newState = state.copyWith(
      email: email,
      password: password,
      submissionStatus: isFormValid ? SubmissionStatus.inProgress : null,
    );

    emit(newState);

    if (isFormValid) {
      //If the fields inserted by the user are valid, send them to
      // the server
      try {
        await userRepository.signIn(
          email.value,
          password.value,
        );

        //When the code gets to this line, it means the server
        // returned a successful response.
        // Set Submission status to success so that you can use
        // this info in your widget to close the screen.
        final newState = state.copyWith(
          submissionStatus: SubmissionStatus.success,
        );

        emit(newState);
      } catch (error) {
        //If the server returns an error, set submissionStatus field
        // to SubmissionStatus.invalidCredentialsException if the
        //cause is missing cred or SubmissionStatus.genericError if
        // the cause is sth else e.g lack of internet connectivity
        final newState = state.copyWith(
          submissionStatus: error is InvalidCredentialsException
              ? SubmissionStatus.invalidCredentialsError
              : SubmissionStatus.genericError,
        );
        emit(newState);
      }
    }
  }
}
