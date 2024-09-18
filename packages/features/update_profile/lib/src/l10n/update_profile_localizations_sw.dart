import 'update_profile_localizations.dart';

/// The translations for Swahili (`sw`).
class UpdateProfileLocalizationsSw extends UpdateProfileLocalizations {
  UpdateProfileLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appBarTitle => 'Sasisha Wasifu';

  @override
  String get updateProfileButtonLabel => 'Sasisha';

  @override
  String get usernameTextFieldLabel => 'Jina la mtumiaji';

  @override
  String get usernameTextFieldEmptyErrorMessage => 'Jina lako la mtumiaji haliwezi kuwa tupu.';

  @override
  String get usernameTextFieldAlreadyTakenErrorMessage => 'Jina hili la mtumiaji lipo. Chagua nyingine.';

  @override
  String get usernameTextFieldInvalidErrorMessage => 'Jina lako la mtumiaji lazima liwe na urefu wa vibambo 1-20, na linaweza tu kuwa na herufi, nambari, na alama ya kusisitiza(_).';

  @override
  String get emailTextFieldLabel => 'Barua Pepe';

  @override
  String get emailTextFieldEmptyErrorMessage => 'Barua pepe yako haiwezi kuwa tupu.';

  @override
  String get emailTextFieldAlreadyRegisteredErrorMessage => 'Barua pepe hii tayari imesajiliwa nasi.';

  @override
  String get emailTextFieldInvalidErrorMessage => 'Barua pepe hii si sahihi.';

  @override
  String get passwordTextFieldLabel => 'Nenosiri mpya';

  @override
  String get passwordTextFieldInvalidErrorMessage => 'Nenosiri lazima liwe na urefu wa angalau vibambo 5.';

  @override
  String get passwordConfirmationTextFieldLabel => 'Uthibitishaji wa Nenosiri Mpya.';

  @override
  String get passwordConfirmationTextFieldInvalidErrorMessage => 'Manenosiri yako hayalingani.';
}
