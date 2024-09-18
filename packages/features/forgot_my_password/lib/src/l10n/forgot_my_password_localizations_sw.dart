import 'forgot_my_password_localizations.dart';

/// The translations for Swahili (`sw`).
class ForgotMyPasswordLocalizationsSw extends ForgotMyPasswordLocalizations {
  ForgotMyPasswordLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get dialogTitle => 'Nimesahau Nenosiri Langu';

  @override
  String get emailTextFieldLabel => 'Barua Pepe';

  @override
  String get emailTextFieldEmptyErrorMessage => 'Barua pepe yako haiwezi kuwa tupu.';

  @override
  String get emailTextFieldInvalidErrorMessage => 'Barua pepe hii si sahihi.';

  @override
  String get emailRequestSuccessMessage => 'Ikiwa umesajili akaunti yako ya barua pepe nasi, kiungo kitatumwa kwako na maagizo ya jinsi ya kuweka upya nenosiri lako.';

  @override
  String get confirmButtonLabel => 'Thibitisha';

  @override
  String get cancelButtonLabel => 'Ghairi';

  @override
  String get errorMessage => 'Hitilafu imetokea, tafadhali angalia muungano wako wa mtandao.';
}
