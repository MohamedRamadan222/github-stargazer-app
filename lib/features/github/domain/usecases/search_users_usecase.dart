import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_user.dart';
import 'package:stargazer_app/core/error/failures.dart';
import 'package:stargazer_app/features/github/domain/repositories/explore_repository.dart';

class SearchUsersUseCase {
  final ExploreRepository repository;

  SearchUsersUseCase(this.repository);

  Future<Either<Failure, List<GithubUser>>> call(
    String query, {
    CancelToken? cancelToken,
  }) {
    return repository.searchUsers(query, cancelToken: cancelToken);
  }
}
