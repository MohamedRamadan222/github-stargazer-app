import 'github_user.dart';

class GithubRepo {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final int stargazersCount;
  final String language;
  final GithubUser owner;

  const GithubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.stargazersCount,
    required this.language,
    required this.owner,
  });
}
