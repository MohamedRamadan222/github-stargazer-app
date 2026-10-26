import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/github_repo.dart';
import '../../../../core/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String username);
  Future<Either<Failure, List<GithubRepo>>> getUserRepos(String username);
  Future<Either<Failure, List<GithubRepo>>> getUserStarredRepos(
    String username,
  );
}
