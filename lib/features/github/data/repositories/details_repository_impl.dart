import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo_details.dart';
import '../../domain/repositories/details_repository.dart';
import '../datasources/details_remote_datasource.dart';

class DetailsRepositoryImpl implements DetailsRepository {
  final DetailsRemoteDatasource remoteDatasource;

  DetailsRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, GithubRepoDetails>> getRepoDetails(
    String owner,
    String repoName,
  ) async {
    try {
      final result = await remoteDatasource.getRepoDetails(owner, repoName);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('فشل في جلب تفاصيل المستودع'));
    }
  }

  @override
  Future<Either<Failure, String>> getRepoReadme(
    String owner,
    String repoName,
  ) async {
    try {
      final result = await remoteDatasource.getRepoReadme(owner, repoName);
      return Right(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right('لا يوجد ملف README متاح لهذا المستودع.');
      }
      return const Left(ServerFailure('فشل في جلب ملف README'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getRepoLanguages(
    String owner,
    String repoName,
  ) async {
    try {
      final languagesMap = await remoteDatasource.getRepoLanguages(
        owner,
        repoName,
      );
      if (languagesMap.isEmpty) return const Right({});

      final totalBytes = languagesMap.values.reduce((a, b) => a + b);
      final percentages = languagesMap.map((key, value) {
        return MapEntry(key, (value / totalBytes) * 100);
      });

      return Right(percentages);
    } catch (e) {
      return const Left(ServerFailure('فشل في جلب لغات البرمجة'));
    }
  }
}
