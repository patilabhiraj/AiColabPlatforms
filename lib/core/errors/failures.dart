abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class EmailVerificationFailure extends Failure {
  final String email;
  const EmailVerificationFailure(this.email, super.message);
}
