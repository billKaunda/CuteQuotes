import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:domain_models/domain_models.dart';

extension UserRMToDomain on UserRM {
  User toDomainModel() {
    return User(
      username: username,
      email: email,
    );
  }
}
