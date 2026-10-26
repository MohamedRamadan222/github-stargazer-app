import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../repositories/profile_repository.dart';

class GetUserStarredReposUseCase {
  final ProfileRepository repository;
  GetUserStarredReposUseCase(this.repository);

  Future<Either<Failure, List<GithubRepo>>> call(String username) {
    return repository.getUserStarredRepos(username);
  }
}
