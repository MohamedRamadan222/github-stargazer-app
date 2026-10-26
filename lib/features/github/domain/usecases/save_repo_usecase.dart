import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../repositories/saved_repository.dart';

class SaveRepoUseCase {
  final SavedRepository repository;
  SaveRepoUseCase(this.repository);

  Future<Either<Failure, void>> call(GithubRepo repo) =>
      repository.saveRepo(repo);
}
