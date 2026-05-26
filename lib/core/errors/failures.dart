// ─── Domain-layer Failures (sealed class pattern) ────────────────────────────

sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class NetworkFailure   extends Failure { const NetworkFailure(super.m); }
final class ServerFailure    extends Failure {
  final int? statusCode;
  const ServerFailure(super.m, {this.statusCode});
}
final class CacheFailure     extends Failure { const CacheFailure(super.m); }
final class LocationFailure  extends Failure { const LocationFailure(super.m); }
final class NotFoundFailure  extends Failure { const NotFoundFailure(super.m); }
final class UnknownFailure   extends Failure { const UnknownFailure(super.m); }

// ─── Data-layer Exceptions ────────────────────────────────────────────────────

sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  const AppException({required this.message, this.statusCode});
  @override String toString() => '$runtimeType: $message';
}

final class NetworkException  extends AppException {
  const NetworkException({required super.message});
}
final class ServerException   extends AppException {
  const ServerException({required super.message, super.statusCode});
}
final class CacheException    extends AppException {
  const CacheException({required super.message});
}
final class LocationException extends AppException {
  const LocationException({required super.message});
}
final class NotFoundException extends AppException {
  const NotFoundException({required super.message});
}
