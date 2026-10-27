import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stargazer_app/core/domain/entities/github_repo.dart';
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
    } on DioException catch (e) {
      // 1. اصطياد الإلغاء
      if (e.type == DioExceptionType.cancel) {
        return const Left(ServerFailure('تم إلغاء الطلب'));
      }

      // 2. اصطياد الـ Rate Limit
      if (e.response?.statusCode == 403) {
        final resetString = e.response?.headers.value('x-ratelimit-reset');
        if (resetString != null) {
          final resetEpoch = int.tryParse(resetString) ?? 0;
          final resetTime = DateTime.fromMillisecondsSinceEpoch(
            resetEpoch * 1000,
            isUtc: true,
          ).toLocal();

          return Left(
            RateLimitFailure(
              'تخطينا الحد المسموح. جرب تاني الساعة ${resetTime.hour}:${resetTime.minute.toString().padLeft(2, '0')}',
              resetTime,
            ),
          );
        }
      }

      // 3. أخطاء السيرفر أو الإنترنت
      return const Left(
        ServerFailure('حصل مشكلة في الاتصال بالإنترنت أو السيرفر'),
      );
    } catch (e) {
      return const Left(ServerFailure('حصل خطأ غير متوقع'));
    }
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
  Future<Either<Failure, List<GithubRepo>>> searchRepos(
    String query, {
    int page = 1,
    CancelToken? cancelToken,
  }) {
    return _handelExceptions(
      () => remoteDatasource.searchRepos(
        query,
        page: page,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<Either<Failure, List<GithubRepo>>> getTrendingRepos({
    int page = 1,
    CancelToken? cancelToken,
  }) {
    return _handelExceptions(
      () => remoteDatasource.getTrendingRepos(
        page: page,
        cancelToken: cancelToken,
      ),
    );
  }
}
