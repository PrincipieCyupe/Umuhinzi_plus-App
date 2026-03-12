import 'package:equatable/equatable.dart';

/// Abstract class representing a failure in the application.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents a failure related to the server/database.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Represents a failure related to the local cache or preferences.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
