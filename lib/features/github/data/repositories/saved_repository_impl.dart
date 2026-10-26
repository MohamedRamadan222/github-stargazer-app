import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/error/failures.dart';
import 'package:stargazer_app/features/github/data/datasources/saved_local_data_source.dart';
import 'package:stargazer_app/features/github/data/models/saved_repo_model.dart';
import 'package:stargazer_app/features/github/domain/repositories/saved_repository.dart';

class SavedRepositoryImpl implements SavedRepository {
  final SavedLocalDataSource localDataSource;

  SavedRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, List<GithubRepo>> getSavedRepo() {
    try {
      final models = localDataSource.getSavedRepos();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (_) {
      return const Left(ServerFailure('فشل في جلب المحفوظات'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRepo(GithubRepo repo) async {
    try {
      await localDataSource.saveRepo(SavedRepoModel.fromEntity(repo));
      return const Right(null);
    } catch (e) {
      print(
        '🔥 خطأ في الـ Hive أثناء الحفظ: $e',
      ); // السطر ده هيكشفلنا لو في مصيبة
      return const Left(ServerFailure('فشل في حفظ المستودع'));
    }
  }

  @override
  Future<Either<Failure, void>> removeRepo(int id) async {
    try {
      await localDataSource.removeRepo(id);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('فشل في الحذف'));
    }
  }
}
