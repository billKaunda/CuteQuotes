import 'package:domain_models/domain_models.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:user_repository/src/mappers/mappers.dart';
import 'package:test/test.dart';

//Add test for DarkModePreferenceCM to DarkModePreference mapper
//Main is the entry point of your test in the program.
void main() {
  //With a group, you can join multiple tests together
  group('Mapper test:', () {
    test(
        'When mapping DarkModePreferenceCM.alwaysDark to domain model, return '
        'DarkModePreference.alwaysDark', () {
      final pref = DarkModePreferenceCM.alwaysDark;
      expect(pref.toDomainModel(), DarkModePreference.alwaysDark);
    });
    test(
        'When mapping DarkModePreference.alwaysLight to cache model, return '
        'DarkModePreferenceCM.alwaysLight', () {
      final pref = DarkModePreference.alwaysLight;
      expect(pref.toCacheModel(), DarkModePreferenceCM.alwaysLight);
    });
  });
}
