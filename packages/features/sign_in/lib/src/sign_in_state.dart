part of 'sign_in_cubit.dart';

enum SubmissionStatus {
  //Used when the form hasn't been sent yet
  idle,

  //Used to disable all buttons and add a progress indicator to the
  // main one
  inProgress,

  //Used to close the screen and navigate to the caller screen
  success,

  //Used to display a snack bar denoting that an error occured, e.g,
  // no internet connection
  genericError,

  //Used to show a more specific error telling the user if the email
  //or password field is invalid
  invalidCredentialsError,
}

class SignInState extends Equatable {
  const SignInState({
    this.email = const Email.unvalidated(),
    this.password = const Password.unvalidated(),
    this.submissionStatus = SubmissionStatus.idle,
  });

  final Email email;
  final Password password;
  final SubmissionStatus submissionStatus;

  SignInState copyWith({
    Email? email,
    Password? password,
    SubmissionStatus? submissionStatus,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        submissionStatus,
      ];
}
