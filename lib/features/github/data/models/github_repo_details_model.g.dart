// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_repo_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubRepoDetailsModel _$GithubRepoDetailsModelFromJson(
  Map<String, dynamic> json,
) => GithubRepoDetailsModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  fullName: json['full_name'] as String,
  description: json['description'] as String? ?? '',
  stargazersCount: (json['stargazers_count'] as num).toInt(),
  language: json['language'] as String? ?? 'Unknown',
  owner: GithubUserModel.fromJson(json['owner'] as Map<String, dynamic>),
  subscribersCount: (json['subscribers_count'] as num).toInt(),
  topics:
      (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$GithubRepoDetailsModelToJson(
  GithubRepoDetailsModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'full_name': instance.fullName,
  'description': instance.description,
  'stargazers_count': instance.stargazersCount,
  'language': instance.language,
  'subscribers_count': instance.subscribersCount,
  'topics': instance.topics,
  'owner': instance.owner,
};
