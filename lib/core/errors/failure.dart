sealed class Failure {
  const Failure({required this.message, this.code, this.stackTrace});
  final String message;
  final String? code;
  final StackTrace? stackTrace;
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.stackTrace});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code, super.stackTrace});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.stackTrace});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code, super.stackTrace});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code, super.stackTrace});
}
