import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/saved_repository.dart';

class RemoveRepoUseCase {
  final SavedRepository repository;

  RemoveRepoUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) => repository.removeRepo(id);
}
