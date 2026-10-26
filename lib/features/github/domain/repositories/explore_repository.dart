import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../../../../core/domain/entities/github_user.dart';

abstract class ExploreRepository {
  Future<Either<Failure, List<GithubRepo>>> searchRepos(
    String query, {
    CancelToken? cancelToken,
  });
  Future<Either<Failure, List<GithubUser>>> searchUsers(
    String query, {
    CancelToken? cancelToken,
  });
  Future<Either<Failure, List<GithubRepo>>> getTrendingRepos({
    CancelToken? cancelToken,
  });
}
