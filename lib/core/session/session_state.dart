part of 'session_cubit.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

/// Estado inicial, aún no se sabe si el usuario está autenticado
class UnknownSessionState extends SessionState {
  const UnknownSessionState();
}

/// El usuario está autenticado
class AuthenticatedSessionState extends SessionState {
  final UserEntity user;
  final String token;

  const AuthenticatedSessionState({required this.user, required this.token});

  @override
  List<Object> get props => [user, token];
}

/// El usuario no está autenticado
class UnauthenticatedSessionState extends SessionState {
  const UnauthenticatedSessionState();
}