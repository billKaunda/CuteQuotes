import './user_info_rm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request_rm.g.dart';

@JsonSerializable(createFactory: false)
class SignUpRequestRM {
  const SignUpRequestRM({required this.user});

  @JsonKey(name: 'user')
  final UserInfoRM user;

  Map<String, dynamic> toJson() => _$SignUpRequestRMToJson(this);
}
