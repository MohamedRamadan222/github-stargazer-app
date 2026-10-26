import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/details_repository.dart';

class GetRepoLanguagesUseCase {
  final DetailsRepository repository;
  GetRepoLanguagesUseCase(this.repository);

  Future<Either<Failure, Map<String, double>>> call(
    String owner,
    String repoName,
  ) {
    return repository.getRepoLanguages(owner, repoName);
  }
}
