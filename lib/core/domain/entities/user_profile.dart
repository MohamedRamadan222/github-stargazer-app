import 'github_user.dart';

class UserProfile extends GithubUser {
  final String? name;
  final String? bio;
  final int followers;
  final int following;
  final int publicRepos;

  const UserProfile({
    required super.id,
    required super.login,
    required super.avatarUrl,
    this.name,
    this.bio,
    required this.followers,
    required this.following,
    required this.publicRepos,
  });
}
