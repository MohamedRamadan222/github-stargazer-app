import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;
  ProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String username) async {
    try {
      final result = await remoteDatasource.getUserProfile(username);
      return Right(result);
    } catch (e) {
      return const Left(ServerFailure('فشل في جلب بيانات المستخدم'));
    }
  }

  @override
  Future<Either<Failure, List<GithubRepo>>> getUserRepos(
    String username,
  ) async {
    try {
      final repos = await remoteDatasource.getUserRepos(username);
      // بنرتب المستودعات هنا من الأعلى للأقل في عدد النجوم
      repos.sort((a, b) => b.stargazersCount.compareTo(a.stargazersCount));
      return Right(repos);
    } catch (e) {
      return const Left(ServerFailure('فشل في جلب مستودعات المستخدم'));
    }
  }

  @override
  Future<Either<Failure, List<GithubRepo>>> getUserStarredRepos(
    String username,
  ) async {
    try {
      final repos = await remoteDatasource.getUserStarredRepos(username);
      return Right(repos);
    } catch (e) {
      return const Left(ServerFailure('فشل في جلب المستودعات المفضلة'));
    }
  }
}
