import 'package:hive_ce/hive.dart';
import 'package:stargazer_app/features/github/data/models/saved_repo_model.dart';

abstract class SavedLocalDataSource {
  List<SavedRepoModel> getSavedRepos();

  Future<void> saveRepo(SavedRepoModel rpo);

  Future<void> removeRepo(int id);
}

class SavedLocalDataSourceImpl implements SavedLocalDataSource {
  final Box<SavedRepoModel> box;

  SavedLocalDataSourceImpl(this.box);

  @override
  List<SavedRepoModel> getSavedRepos() => box.values.toList();

  @override
  Future<void> saveRepo(SavedRepoModel repo) async =>
      await box.put(repo.id, repo);

  @override
  Future<void> removeRepo(int id) async => await box.delete(id);
}
