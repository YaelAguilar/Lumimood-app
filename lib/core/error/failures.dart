import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message, [List properties = const <dynamic>[]]);

  @override
  List<Object?> get props => [message];
}

/// Falla general del servidor (errores 5xx, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Falla por datos inválidos o recurso no encontrado (errores 4xx)
class ClientFailure extends Failure {
  const ClientFailure(super.message);
}

/// Falla de la caché local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}