import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import '../../features/authentication/domain/entities/user_entity.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final SharedPreferences sharedPreferences;

  SessionCubit({required this.sharedPreferences}) : super(const UnknownSessionState()) {
    _loadSession();
  }

  /// Carga la sesión existente al inicializar
  void _loadSession() {
    try {
      final token = sharedPreferences.getString('jwt_token');
      final userId = sharedPreferences.getString('user_id');
      final userEmail = sharedPreferences.getString('user_email');
      final userName = sharedPreferences.getString('user_name');
      final userTypeString = sharedPreferences.getString('user_type');

      if (token != null && userId != null && userEmail != null && userName != null && userTypeString != null) {
        final userType = userTypeString == 'AccountType.specialist' 
          ? AccountType.specialist 
          : AccountType.patient;

        final user = UserEntity(
          id: userId,
          email: userEmail,
          name: userName,
          typeAccount: userType,
          token: token,
        );

        log('📱 SESSION: Restored existing session for ${user.email}');
        emit(AuthenticatedSessionState(user: user, token: token));
      } else {
        log('📱 SESSION: No existing session found');
        emit(const UnauthenticatedSessionState());
      }
    } catch (e) {
      log('❌ SESSION: Error loading session - $e');
      emit(const UnauthenticatedSessionState());
    }
  }

  Future<void> showSession(UserEntity user, String token) async {
    try {
      log('💾 SESSION: Saving session for ${user.email} (${user.typeAccount.name})');
      
      // Guardar en SharedPreferences
      await Future.wait([
        sharedPreferences.setString('jwt_token', token),
        sharedPreferences.setString('user_id', user.id),
        sharedPreferences.setString('user_email', user.email),
        sharedPreferences.setString('user_name', user.name),
        sharedPreferences.setString('user_type', user.typeAccount.toString()),
      ]);

      // Emitir el nuevo estado
      emit(AuthenticatedSessionState(user: user, token: token));
      log('✅ SESSION: Session saved and state updated successfully');
    } catch (e) {
      log('❌ SESSION: Error saving session - $e');
      // En caso de error, mantener estado no autenticado
      emit(const UnauthenticatedSessionState());
    }
  }

  Future<void> signOut() async {
    try {
      log('🚪 SESSION: Signing out...');
      await sharedPreferences.clear();
      emit(const UnauthenticatedSessionState());
      log('✅ SESSION: Sign out completed');
    } catch (e) {
      log('❌ SESSION: Error signing out - $e');
      // Forzar estado no autenticado incluso si hay error
      emit(const UnauthenticatedSessionState());
    }
  }

  /// Verifica si hay una sesión activa
  bool get isAuthenticated => state is AuthenticatedSessionState;

  /// Obtiene el usuario actual si está autenticado
  UserEntity? get currentUser {
    final currentState = state;
    if (currentState is AuthenticatedSessionState) {
      return currentState.user;
    }
    return null;
  }

  /// Obtiene el token actual si está autenticado
  String? get currentToken {
    final currentState = state;
    if (currentState is AuthenticatedSessionState) {
      return currentState.token;
    }
    return null;
  }
}