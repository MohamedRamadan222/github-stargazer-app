import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/error/failures.dart';
import 'package:stargazer_app/features/github/domain/repositories/saved_repository.dart';

class GetSavedReposUseCase {
  final SavedRepository repository;

  GetSavedReposUseCase(this.repository);

  Either<Failure, List<GithubRepo>> call() => repository.getSavedRepo();
}
