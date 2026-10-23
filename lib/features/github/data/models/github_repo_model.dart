import 'package:json_annotation/json_annotation.dart';

import '../../../../core/domain/entities/github_repo.dart';
import 'github_user_model.dart';

part 'github_repo_model.g.dart';

@JsonSerializable()
class GithubRepoModel extends GithubRepo {

  // ignore: overridden_fields
  @override
  final GithubUserModel owner;

  const GithubRepoModel({
    required super.id,
    required super.name,
    @JsonKey(name: 'full_name') required super.fullName,
    super.description = '',
    @JsonKey(name: 'stargazers_count') required super.stargazersCount,
    super.language = 'Unknown',
    required this.owner,
  }) : super(owner: owner);

  factory GithubRepoModel.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubRepoModelToJson(this);
}
