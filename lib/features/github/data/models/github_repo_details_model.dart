import 'package:json_annotation/json_annotation.dart';

import '../../../../core/domain/entities/github_repo_details.dart';
import 'github_user_model.dart';

part 'github_repo_details_model.g.dart';

@JsonSerializable()
class GithubRepoDetailsModel extends GithubRepoDetails {
  // ignore: overridden_fields
  @override
  final GithubUserModel owner;

  const GithubRepoDetailsModel({
    required super.id,
    required super.name,
    @JsonKey(name: 'full_name') required super.fullName,
    super.description = '',
    @JsonKey(name: 'stargazers_count') required super.stargazersCount,
    super.language = 'Unknown',
    required this.owner,
    @JsonKey(name: 'subscribers_count') required super.subscribersCount,
    super.topics = const [],
  }) : super(owner: owner);

  factory GithubRepoDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDetailsModelFromJson(json);
}
