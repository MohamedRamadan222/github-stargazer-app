import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;
  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(String username) {
    return repository.getUserProfile(username);
  }
}
