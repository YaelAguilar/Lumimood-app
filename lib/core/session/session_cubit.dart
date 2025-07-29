import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'dart:math' as math;
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

      log('🔍 SESSION LOAD: Checking existing session...');
      log('🔍 SESSION LOAD: Token exists: ${token != null}');
      log('🔍 SESSION LOAD: UserId: $userId');
      log('🔍 SESSION LOAD: UserEmail: $userEmail');
      log('🔍 SESSION LOAD: UserName: $userName');
      log('🔍 SESSION LOAD: UserType: $userTypeName');

      if (token != null && userId != null && userEmail != null && userName != null && userTypeName != null) {
        log('🔍 SESSION: Loading user type from storage: $userTypeName');
        log('🔍 SESSION: Token first 20 chars: ${token.substring(0, math.min(20, token.length))}...');
        
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
        log('🔍 SESSION: Missing components - Token: ${token != null}, UserId: ${userId != null}, Email: ${userEmail != null}, Name: ${userName != null}, Type: ${userTypeName != null}');
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
      log('💾 SESSION: Token to save: ${token.substring(0, math.min(20, token.length))}...');
      log('💾 SESSION: Token length: ${token.length}');
      log('💾 SESSION: Saving user type as string: ${user.typeAccount.name}');
      
      // Guardar en SharedPreferences
      await Future.wait([
        sharedPreferences.setString(_tokenKey, token),
        sharedPreferences.setString(_userIdKey, user.id),
        sharedPreferences.setString(_userEmailKey, user.email),
        sharedPreferences.setString(_userNameKey, user.name),
        sharedPreferences.setString(_userTypeKey, user.typeAccount.name),
      ]);

      // DEBUGGING: Verificar que se guardó correctamente
      final savedToken = sharedPreferences.getString(_tokenKey);
      final savedUserId = sharedPreferences.getString(_userIdKey);
      final savedUserEmail = sharedPreferences.getString(_userEmailKey);
      final savedUserName = sharedPreferences.getString(_userNameKey);
      final savedUserType = sharedPreferences.getString(_userTypeKey);
      
      log('🔍 SESSION DEBUG: Verification after save:');
      log('🔍 SESSION DEBUG: Token saved successfully: ${savedToken != null}');
      log('🔍 SESSION DEBUG: UserId saved: ${savedUserId != null} ($savedUserId)');
      log('🔍 SESSION DEBUG: Email saved: ${savedUserEmail != null} ($savedUserEmail)');
      log('🔍 SESSION DEBUG: Name saved: ${savedUserName != null} ($savedUserName)');
      log('🔍 SESSION DEBUG: Type saved: ${savedUserType != null} ($savedUserType)');
      
      if (savedToken != null) {
        log('🔍 SESSION DEBUG: Saved token matches: ${savedToken == token}');
        log('🔍 SESSION DEBUG: Saved token first 20 chars: ${savedToken.substring(0, math.min(20, savedToken.length))}...');
      }

      // DEBUGGING: Listar todas las claves guardadas
      final allKeys = sharedPreferences.getKeys();
      log('🔍 SESSION DEBUG: All keys in SharedPreferences: $allKeys');

      // Emitir el nuevo estado
      emit(AuthenticatedSessionState(user: user, token: token));
      log('✅ SESSION: Session saved and state updated successfully');
      
      // Verificar el estado emitido
      final currentState = state;
      if (currentState is AuthenticatedSessionState) {
        log('✅ SESSION: State verification - User: ${currentState.user.email}, Token exists: ${currentState.token.isNotEmpty}');
      }
      
    } catch (e) {
      log('❌ SESSION: Error saving session - $e');
      emit(const UnauthenticatedSessionState());
    }
  }

  Future<void> signOut() async {
    try {
      log('🚪 SESSION: Signing out...');
      
      // Mostrar qué hay antes de limpiar
      final currentKeys = sharedPreferences.getKeys();
      log('🔍 SESSION: Keys before cleanup: $currentKeys');
      
      await Future.wait([
        sharedPreferences.remove(_tokenKey),
        sharedPreferences.remove(_userIdKey),
        sharedPreferences.remove(_userEmailKey),
        sharedPreferences.remove(_userNameKey),
        sharedPreferences.remove(_userTypeKey),
      ]);
      
      // Verificar que se limpiaron
      final remainingKeys = sharedPreferences.getKeys();
      log('🔍 SESSION: Keys after cleanup: $remainingKeys');
      
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
      log('🔍 SESSION: Getting current user: ${currentState.user.email}');
      return currentState.user;
    }
    log('⚠️ SESSION: No current user - state is ${currentState.runtimeType}');
    return null;
  }

  /// Obtiene el token actual si está autenticado
  String? get currentToken {
    final currentState = state;
    if (currentState is AuthenticatedSessionState) {
      final token = currentState.token;
      log('🔍 SESSION: Getting current token - exists: ${token.isNotEmpty}, length: ${token.length}');
      return token;
    }
    log('⚠️ SESSION: No current token - state is ${currentState.runtimeType}');
    return null;
  }
}