abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class RateLimitFailure extends Failure {
  final DateTime resetTime;

  const RateLimitFailure(super.message, this.resetTime);
}
