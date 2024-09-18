import 'profile_menu_localizations.dart';

/// The translations for English (`en`).
class ProfileMenuLocalizationsEn extends ProfileMenuLocalizations {
  ProfileMenuLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signInButtonLabel => 'Sign In';

  @override
  String signInUserGreeting(String username) {
    return 'Hello $username ';
  }

  @override
  String get updateProfileTileLabel => 'Update Profile';

  @override
  String get darkModePreferencesHeaderTileLabel => 'Dark Mode Preference';

  @override
  String get darkModePreferencesAlwaysDarkTileLabel => 'Always Dark';

  @override
  String get darkModePreferencesAlwaysLightTileLabel => 'Always Light';

  @override
  String get darkModePreferencesUseSystemSettingsTileLabel => 'Use System Settings';

  @override
  String get signOutButtonLabel => 'Sign Out';

  @override
  String get signUpOpeningText => 'Don\'t have an account?';

  @override
  String get signUpButtonLabel => 'Sign Up';
}
