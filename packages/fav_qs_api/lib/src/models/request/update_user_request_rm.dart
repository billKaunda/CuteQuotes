import 'package:fav_qs_api/src/models/request/user_info_rm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_user_request_rm.g.dart';

@JsonSerializable(createFactory: false)
class UpdateUserRequestRM {
  const UpdateUserRequestRM({required this.user});

  @JsonKey(name: 'user')
  final UserInfoRM user;

  Map<String, dynamic> toJson() => _$UpdateUserRequestRMToJson(this);
}
