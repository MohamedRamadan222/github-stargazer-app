class ServerException implements Exception {
  final String? message;

  ServerException({this.message});
}

class RateLimitException implements Exception {
  final DateTime resetTime;

  RateLimitException({required this.resetTime});
}
