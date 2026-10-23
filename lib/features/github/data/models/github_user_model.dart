import 'package:json_annotation/json_annotation.dart';
import '../../../../core/domain/entities/github_user.dart';

part 'github_user_model.g.dart';

@JsonSerializable()
class GithubUserModel extends GithubUser {
  const GithubUserModel({
    required super.id,
    required super.login,
    @JsonKey(name: 'avatar_url') required super.avatarUrl,
  });

  factory GithubUserModel.fromJson(Map<String, dynamic> json) =>
      _$GithubUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubUserModelToJson(this);
}