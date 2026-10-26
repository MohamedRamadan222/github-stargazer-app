import 'github_repo.dart';

class GithubRepoDetails extends GithubRepo {
  final int subscribersCount;
  final List<String> topics;

  const GithubRepoDetails({
    required super.id,
    required super.name,
    required super.fullName,
    required super.description,
    required super.stargazersCount,
    required super.language,
    required super.owner,
    required this.subscribersCount,
    required this.topics,
  });
}
