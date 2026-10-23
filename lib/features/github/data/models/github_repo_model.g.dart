// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_repo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubRepoModel _$GithubRepoModelFromJson(Map<String, dynamic> json) =>
    GithubRepoModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String? ?? '',
      stargazersCount: (json['stargazers_count'] as num).toInt(),
      language: json['language'] as String? ?? 'Unknown',
      owner: GithubUserModel.fromJson(json['owner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GithubRepoModelToJson(GithubRepoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'full_name': instance.fullName,
      'description': instance.description,
      'stargazers_count': instance.stargazersCount,
      'language': instance.language,
      'owner': instance.owner,
    };
