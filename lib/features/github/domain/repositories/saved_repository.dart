import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/error/failures.dart';

abstract class SavedRepository {
  Either<Failure, List<GithubRepo>> getSavedRepo();
  Future<Either<Failure, void>> saveRepo(GithubRepo repo);
  Future<Either<Failure, void>> removeRepo(int id);
}
