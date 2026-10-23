import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
import 'package:stargazer_app/core/error/exceptions.dart';
import 'package:stargazer_app/core/error/failures.dart';
import 'package:stargazer_app/features/github/data/datasources/explore_remote_datasource.dart';
import 'package:stargazer_app/features/github/domain/repositories/explore_repository.dart';

import '../../../../core/domain/entities/github_user.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDatasource remoteDatasource;

  ExploreRepositoryImpl(this.remoteDatasource);

  Future<Either<Failure, T>> _handelExceptions<T>(
    Future<T> Function() apiCall,
  ) async {
    try {
      final result = await apiCall();
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(
        RateLimitFailure(
          'تخطينا الحد المسموح. جرب تاني الساعة ${e.resetTime.hour}:${e.resetTime.minute}',
          e.resetTime,
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const Left(ServerFailure('تم إلغاء الطلب'));
      }
      return const Left(
        ServerFailure('حصل مشكلة في الاتصال بالانترنت أو السيرفر'),
      );
    } catch (e) {
      return const Left(ServerFailure('حصل خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, List<GithubRepo>>> searchRepos(
    String query, {
    CancelToken? cancelToken,
  }) {
    return _handelExceptions(
      () => remoteDatasource.searchRepos(query, cancelToken: cancelToken),
    );
  }

  @override
  Future<Either<Failure, List<GithubUser>>> searchUsers(
    String query, {
    CancelToken? cancelToken,
  }) {
    return _handelExceptions(
      () => remoteDatasource.searchUsers(query, cancelToken: cancelToken),
    );
  }

  @override
  Future<Either<Failure, List<GithubRepo>>> getTrendingRepos({
    CancelToken? cancelToken,
  }) {
    return _handelExceptions(
      () => remoteDatasource.getTrendingRepos(cancelToken: cancelToken),
    );
  }
}
