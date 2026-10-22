import 'package:hive_ce/hive.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/domain/entities/github_user.dart';

part 'saved_repo_model.g.dart';

@HiveType(typeId: 0)
class SavedRepoModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String fullName;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final int stargazersCount;
  @HiveField(5)
  final String language;
  @HiveField(6)
  final int ownerId;
  @HiveField(7)
  final String ownerLogin;
  @HiveField(8)
  final String ownerAvatarUrl;

  SavedRepoModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.stargazersCount,
    required this.language,
    required this.ownerId,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
  });

  factory SavedRepoModel.fromEntity(GithubRepo entity) {
    return SavedRepoModel(
      id: entity.id,
      name: entity.name,
      fullName: entity.fullName,
      description: entity.description,
      stargazersCount: entity.stargazersCount,
      language: entity.language,
      ownerId: entity.owner.id,
      ownerLogin: entity.owner.login,
      ownerAvatarUrl: entity.owner.avatarUrl,
    );
  }

  GithubRepo toEntity() {
    return GithubRepo(
      id: id,
      name: name,
      fullName: fullName,
      description: description,
      stargazersCount: stargazersCount,
      language: language,
      owner: GithubUser(
        id: ownerId,
        login: ownerLogin,
        avatarUrl: ownerAvatarUrl,
      ),
    );
  }
}
