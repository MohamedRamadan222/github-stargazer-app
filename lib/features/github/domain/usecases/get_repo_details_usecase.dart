import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo_details.dart';
import '../repositories/details_repository.dart';

class GetRepoDetailsUseCase {
  final DetailsRepository repository;
  GetRepoDetailsUseCase(this.repository);

  Future<Either<Failure, GithubRepoDetails>> call(
    String owner,
    String repoName,
  ) {
    return repository.getRepoDetails(owner, repoName);
  }
}
