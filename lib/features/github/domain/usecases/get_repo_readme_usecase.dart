import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/details_repository.dart';

class GetRepoReadmeUseCase {
  final DetailsRepository repository;
  GetRepoReadmeUseCase(this.repository);

  Future<Either<Failure, String>> call(String owner, String repoName) {
    return repository.getRepoReadme(owner, repoName);
  }
}
