import 'package:domain_models/domain_models.dart';
import 'package:key_value_storage/key_value_storage.dart';

extension DarkModePreferencesDomainToCM on DarkModePreference {
  DarkModePreferenceCM toCacheModel() {
    switch (this) {
      case DarkModePreference.alwaysDark:
        return DarkModePreferenceCM.alwaysDark;
      case DarkModePreference.alwaysLight:
        return DarkModePreferenceCM.alwaysLight;
      case DarkModePreference.useSystemSettings:
        return DarkModePreferenceCM.accordingToSystemPreferences;
    }
  }
}
