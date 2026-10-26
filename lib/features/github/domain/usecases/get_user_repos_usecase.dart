import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../repositories/profile_repository.dart';

class GetUserReposUseCase {
  final ProfileRepository repository;
  GetUserReposUseCase(this.repository);

  Future<Either<Failure, List<GithubRepo>>> call(String username) {
    return repository.getUserRepos(username);
  }
}
