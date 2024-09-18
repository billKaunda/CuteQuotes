import 'sign_up_localizations.dart';

/// The translations for Swahili (`sw`).
class SignUpLocalizationsSw extends SignUpLocalizations {
  SignUpLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get invalidCredentialsErrorMessage => 'Barua pepe na/au nenosiri si sahihi';

  @override
  String get appBarTitle => 'Jiandikishe';

  @override
  String get signUpButtonLabel => 'Jisandikishe';

  @override
  String get usernameTextFieldLabel => 'Jina la mtumiaji';

  @override
  String get usernameTextFieldEmptyErrorMessage => 'Jina lako la mtumiaji haliwezi kuwa tupu';

  @override
  String get usernameTextFieldInvalidErrorMessage => 'Jina la mtumiaji linaweza kuwa na urefu wa vibambo 1-20 pekee, na linaweza kuwa na herufi, nambari, na alama ya chini pekee.';

  @override
  String get usernameTextFieldAlreadyTakenErrorMessage => 'Jina hili la mtumiaji tayari limechukuliwa.';

  @override
  String get emailTextFieldLabel => 'Barua Pepe';

  @override
  String get emailTextFieldEmptyErrorMessage => 'Barua pepe yako haiwezi kuwa tupu.';

  @override
  String get emailTextFieldInvalidErrorMessage => 'Barua pepe hii si sahihi.';

  @override
  String get emailTextFieldAlreadyRegisteredErrorMessage => 'Samahani, barua pepe hii tayari imesajiliwa nasi.';

  @override
  String get passwordTextFieldLabel => 'Nenosiri';

  @override
  String get passwordTextFieldEmptyErrorMessage => 'Nenosiri lako haliwezi kuwa tupu.';

  @override
  String get passwordTextFieldInvalidErrorMessage => 'Nenosiri lazima liwe na urefu wa angalau vibambo 5.';

  @override
  String get passwordConfirmationTextFieldLabel => 'Uthibitishaji wa Nenosiri';

  @override
  String get passwordConfirmationTextFieldEmptyErrorMessage => 'Sehemu hii haiwezi kuwa tupu.';

  @override
  String get passwordConfirmationTextFieldInvalidErrorMessage => 'Nenosiri lako halilingani.';
}
