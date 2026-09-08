import 'package:equatable/equatable.dart';

/// Ҳама repository/service-ҳо натиҷаро на ба воситаи "throw" -и хом,
/// балки ба воситаи ин Failure-типҳо бармегардонанд (ё бо Either аз
/// package-и dartz дар марҳилаи баъдӣ, агар лозим шавад).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Хатогии сервер рух дод.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Интернет пайваст нест.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Хатогии воридшавӣ рух дод.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Хатогии cache рух дод.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Иҷозат дода нашудааст.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Хатогии номаълум рух дод.']);
}
