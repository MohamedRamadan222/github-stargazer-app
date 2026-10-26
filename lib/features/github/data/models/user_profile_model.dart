import 'package:json_annotation/json_annotation.dart';

import '../../../../core/domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.login,
    @JsonKey(name: 'avatar_url') required super.avatarUrl,
    super.name,
    super.bio,
    super.followers = 0,
    super.following = 0,
    @JsonKey(name: 'public_repos') super.publicRepos = 0,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}
