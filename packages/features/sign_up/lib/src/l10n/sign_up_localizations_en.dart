import 'sign_up_localizations.dart';

/// The translations for English (`en`).
class SignUpLocalizationsEn extends SignUpLocalizations {
  SignUpLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get invalidCredentialsErrorMessage => 'Invalid email and/or password.';

  @override
  String get appBarTitle => 'Sign Up';

  @override
  String get signUpButtonLabel => 'Sign Up';

  @override
  String get usernameTextFieldLabel => 'Username';

  @override
  String get usernameTextFieldEmptyErrorMessage => 'Your username can\'t be empty';

  @override
  String get usernameTextFieldInvalidErrorMessage => 'Username can only be 1-20 characters long, and can contain letters, numbers, and the underscore only.';

  @override
  String get usernameTextFieldAlreadyTakenErrorMessage => 'This username is already taken.';

  @override
  String get emailTextFieldLabel => 'Email';

  @override
  String get emailTextFieldEmptyErrorMessage => 'Your email can\'t be empty.';

  @override
  String get emailTextFieldInvalidErrorMessage => 'This email address is not valid.';

  @override
  String get emailTextFieldAlreadyRegisteredErrorMessage => 'Sorry, this email is already registered with us.';

  @override
  String get passwordTextFieldLabel => 'Password';

  @override
  String get passwordTextFieldEmptyErrorMessage => 'Your password can\'t be empty.';

  @override
  String get passwordTextFieldInvalidErrorMessage => 'Password must be at least 5 characters long.';

  @override
  String get passwordConfirmationTextFieldLabel => 'Password Confirmation';

  @override
  String get passwordConfirmationTextFieldEmptyErrorMessage => 'This field can\'t be emtpy.';

  @override
  String get passwordConfirmationTextFieldInvalidErrorMessage => 'Your password don\'t match.';
}
