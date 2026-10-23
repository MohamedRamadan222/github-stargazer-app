import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../repositories/explore_repository.dart';

class GetTrendingReposUseCase {
  final ExploreRepository repository;
  GetTrendingReposUseCase(this.repository);

  Future<Either<Failure, List<GithubRepo>>> call({CancelToken? cancelToken}) {
    return repository.getTrendingRepos(cancelToken: cancelToken);
  }
}