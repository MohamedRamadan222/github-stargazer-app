import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo_details.dart';

abstract class DetailsRepository {
  Future<Either<Failure, GithubRepoDetails>> getRepoDetails(
    String owner,
    String repoName,
  );

  Future<Either<Failure, String>> getRepoReadme(String owner, String repoName);

  Future<Either<Failure, Map<String, double>>> getRepoLanguages(
    String owner,
    String repoName,
  );
}
