import 'dart:developer';
import '../../domain/entities/user_entity.dart';

// Modelo para la respuesta completa del login
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name, // El nombre lo obtenemos del loginResult
    required super.typeAccount,
    required super.token,
    super.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Log para debug
    log('UserModel.fromJson - Raw JSON: $json');
    
    // Verificar diferentes estructuras de respuesta
    Map<String, dynamic>? loginResult;
    String? token;
    
    if (json.containsKey('loginResult')) {
      // Estructura esperada: { "loginResult": {...}, "token": "..." }
      loginResult = json['loginResult'] as Map<String, dynamic>?;
      token = json['token']?.toString();
    } else if (json.containsKey('user')) {
      // Estructura alternativa: { "user": {...}, "token": "..." }
      loginResult = json['user'] as Map<String, dynamic>?;
      token = json['token']?.toString();
    } else {
      // Estructura directa: el JSON es el usuario mismo
      loginResult = json;
      token = json['token']?.toString() ?? 'dummy_token';
    }
    
    if (loginResult == null) {
      throw Exception('No user data found in response: $json');
    }
    
    log('UserModel.fromJson - loginResult: $loginResult');
    log('UserModel.fromJson - token: $token');
    
    return UserModel(
      id: loginResult['id']?.toString() ?? loginResult['userId']?.toString() ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: loginResult['email']?.toString() ?? '',
      name: loginResult['name']?.toString() ?? loginResult['firstName']?.toString() ?? 'Usuario',
      typeAccount: _parseAccountType(loginResult['typeAccount'] ?? loginResult['accountType'] ?? loginResult['type']),
      token: token ?? 'dummy_token',
    );
  }
  
  static AccountType _parseAccountType(dynamic typeAccount) {
    if (typeAccount == null) return AccountType.patient;
    
    final typeString = typeAccount.toString().toLowerCase();
    switch (typeString) {
      case 'patient':
        return AccountType.patient;
      case 'specialist':
        return AccountType.specialist;
      default:
        log('Unknown account type: $typeAccount, defaulting to patient');
        return AccountType.patient;
    }
  }
}