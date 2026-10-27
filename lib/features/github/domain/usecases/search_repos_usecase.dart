import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../repositories/explore_repository.dart';

class SearchReposUseCase {
  final ExploreRepository repository;
  SearchReposUseCase(this.repository);

  Future<Either<Failure, List<GithubRepo>>> call(
    String query, {
    int page = 1,
    CancelToken? cancelToken,
  }) {
    return repository.searchRepos(query, page: page, cancelToken: cancelToken);
  }
}
