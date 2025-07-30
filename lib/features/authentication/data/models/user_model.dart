import 'dart:developer';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.typeAccount,
    required super.token,
    super.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    log('UserModel.fromJson - Raw JSON: $json');
    
    // Unificar la obtención de datos y token
    Map<String, dynamic> userData;
    String? token;

    if (json.containsKey('loginResult')) {
      userData = json['loginResult'] as Map<String, dynamic>;
      token = json['token']?.toString();
    } else if (json.containsKey('user')) {
      userData = json['user'] as Map<String, dynamic>;
      token = json['token']?.toString();
    } else {
      userData = json;
      token = json['token']?.toString();
    }
    
    // Fail-Fast: Si un campo esencial es nulo, es un error irrecuperable.
    final id = userData['id']?.toString() ?? userData['userId']?.toString();
    if (id == null) {
      throw Exception('Critical field "id" is null in user data: $userData');
    }
    if (token == null) {
      throw Exception('Critical field "token" is null in response: $json');
    }

    return UserModel(
      id: id,
      email: userData['email']?.toString() ?? '',
      name: userData['name']?.toString() ?? userData['firstName']?.toString() ?? 'Usuario',
      typeAccount: _parseAccountType(userData['typeAccount'] ?? userData['accountType'] ?? userData['type']),
      token: token,
    );
  }
  
  // Factory method para combinar login response con información de profesional
  factory UserModel.fromLoginWithProfessional({
    required Map<String, dynamic> loginJson,
    Map<String, dynamic>? professionalJson,
  }) {
    log('UserModel.fromLoginWithProfessional - Login JSON: $loginJson');
    log('UserModel.fromLoginWithProfessional - Professional JSON: $professionalJson');
    
    final Map<String, dynamic> loginResult = loginJson['loginResult'] ?? loginJson;
    final String? token = loginJson['token']?.toString();
    
    // Fail-Fast para campos críticos
    final id = loginResult['id']?.toString();
    if (id == null) {
      throw Exception('Critical field "id" is null in login result: $loginResult');
    }
    if (token == null) {
      throw Exception('Critical field "token" is null in login response: $loginJson');
    }
    
    // Determinar tipo de cuenta y nombre de forma más limpia
    final bool isSpecialist = professionalJson != null;
    final AccountType accountType = isSpecialist ? AccountType.specialist : AccountType.patient;
    
    String name = professionalJson?['name']?.toString() ??
                  professionalJson?['firstName']?.toString() ??
                  loginResult['name']?.toString() ??
                  (isSpecialist ? 'Especialista' : 'Paciente');

    log('✅ User identified as ${accountType.name}: $name');
    
    return UserModel(
      id: id,
      email: loginResult['email']?.toString() ?? '',
      name: name,
      typeAccount: accountType,
      token: token,
    );
  }
  
  // Nuevo factory method para pacientes
  factory UserModel.fromLoginWithPatient({
    required Map<String, dynamic> loginJson,
    Map<String, dynamic>? patientJson,
  }) {
    log('UserModel.fromLoginWithPatient - Login JSON: $loginJson');
    log('UserModel.fromLoginWithPatient - Patient JSON: $patientJson');
    
    final Map<String, dynamic> loginResult = loginJson['loginResult'] ?? loginJson;
    final String? token = loginJson['token']?.toString();
    
    // Fail-Fast para campos críticos
    final id = loginResult['id']?.toString();
    if (id == null) {
      throw Exception('Critical field "id" is null in login result: $loginResult');
    }
    if (token == null) {
      throw Exception('Critical field "token" is null in login response: $loginJson');
    }
    
    // Obtener el nombre del paciente
    String name = patientJson?['name']?.toString() ??
                  patientJson?['firstName']?.toString() ??
                  loginResult['name']?.toString() ??
                  'Paciente';

    log('✅ User identified as patient: $name');
    
    return UserModel(
      id: id,
      email: loginResult['email']?.toString() ?? '',
      name: name,
      typeAccount: AccountType.patient,
      token: token,
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