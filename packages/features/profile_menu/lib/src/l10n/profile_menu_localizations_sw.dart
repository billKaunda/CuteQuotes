import 'profile_menu_localizations.dart';

/// The translations for Swahili (`sw`).
class ProfileMenuLocalizationsSw extends ProfileMenuLocalizations {
  ProfileMenuLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get signInButtonLabel => 'Weka Sahihi';

  @override
  String signInUserGreeting(String username) {
    return 'Hujambo $username ';
  }

  @override
  String get updateProfileTileLabel => 'Sasisha Wasifu';

  @override
  String get darkModePreferencesHeaderTileLabel => 'Upendeleo wa Hali ya Giza';

  @override
  String get darkModePreferencesAlwaysDarkTileLabel => 'Giza ';

  @override
  String get darkModePreferencesAlwaysLightTileLabel => 'Mwanga';

  @override
  String get darkModePreferencesUseSystemSettingsTileLabel => 'Tumia Mipangilio ya Mfumo';

  @override
  String get signOutButtonLabel => 'Toka';

  @override
  String get signUpOpeningText => 'Je, huna akaunti?';

  @override
  String get signUpButtonLabel => 'Jisajili';
}
