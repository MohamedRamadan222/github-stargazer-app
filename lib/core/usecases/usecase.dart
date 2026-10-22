import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

abstract class UseCase<type, Params> {
  Future<Either<Failure, type>> call(Params params);
}
