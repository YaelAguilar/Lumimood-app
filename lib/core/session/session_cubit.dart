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

  // Claves para SharedPreferences
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userTypeKey = 'user_type';

  /// Carga la sesión existente al inicializar
  void _loadSession() {
    try {
      final token = sharedPreferences.getString(_tokenKey);
      final userId = sharedPreferences.getString(_userIdKey);
      final userEmail = sharedPreferences.getString(_userEmailKey);
      final userName = sharedPreferences.getString(_userNameKey);
      final userTypeName = sharedPreferences.getString(_userTypeKey);

      if (token != null && userId != null && userEmail != null && userName != null && userTypeName != null) {
        log('🔍 SESSION: Loading user type from storage: $userTypeName');
        
        final userType = AccountType.values.firstWhere(
          (type) => type.name == userTypeName,
          orElse: () {
            log('⚠️ SESSION: Could not parse "$userTypeName", defaulting to patient.');
            return AccountType.patient; // Valor por defecto si no se encuentra
          },
        );
        log('🔍 SESSION: Parsed user type as: ${userType.name}');

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
      
      log('💾 SESSION: Saving user type as string: ${user.typeAccount.name}');
      
      // Guardar en SharedPreferences
      await Future.wait([
        sharedPreferences.setString(_tokenKey, token),
        sharedPreferences.setString(_userIdKey, user.id),
        sharedPreferences.setString(_userEmailKey, user.email),
        sharedPreferences.setString(_userNameKey, user.name),
        sharedPreferences.setString(_userTypeKey, user.typeAccount.name),
      ]);

      // Emitir el nuevo estado
      emit(AuthenticatedSessionState(user: user, token: token));
      log('✅ SESSION: Session saved and state updated successfully');
    } catch (e) {
      log('❌ SESSION: Error saving session - $e');
      emit(const UnauthenticatedSessionState());
    }
  }

  Future<void> signOut() async {
    try {
      log('🚪 SESSION: Signing out...');
      await Future.wait([
        sharedPreferences.remove(_tokenKey),
        sharedPreferences.remove(_userIdKey),
        sharedPreferences.remove(_userEmailKey),
        sharedPreferences.remove(_userNameKey),
        sharedPreferences.remove(_userTypeKey),
      ]);
      emit(const UnauthenticatedSessionState());
      log('✅ SESSION: Sign out completed');
    } catch (e) {
      log('❌ SESSION: Error signing out - $e');
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