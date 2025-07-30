import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/register_specialist.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password, required String typeAccount});
  Future<void> register(RegisterParams params);
  Future<void> registerSpecialist(RegisterSpecialistParams params);
  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password, required String typeAccount}) async {
    log('🚀 AuthRemoteDataSource.login() CALLED - Email: $email, User selected type: $typeAccount');
    
    try {
      // Paso 1: Autenticar contra el servicio de identidad (enviando también el rol esperado)
      final response = await apiClient.post(
        '${ApiConfig.identityBaseUrl}/login',
        {
          'email': email, 
          'password': password,
          'rol': _convertTypeAccountToBackendRole(typeAccount), // Enviar el rol esperado
        },
      );

      log('Identity service response status: ${response.statusCode}');
      log('Identity service response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(errorBody['message'] ?? 'Credenciales inválidas');
      }

      final responseBody = json.decode(response.body);
      final loginResult = responseBody['loginResult'];
      final token = responseBody['token']?.toString();
      
      if (loginResult == null || token == null) {
        throw ServerException('Respuesta de autenticación inválida del servidor.');
      }

      // Paso 2: Extraer el rol real del usuario desde el backend
      final backendRole = loginResult['rol']?.toString();
      final userId = loginResult['id']?.toString();
      final userEmail = loginResult['email']?.toString() ?? email;
      
      if (backendRole == null) {
        throw ServerException('Rol de usuario no encontrado en la respuesta del servidor.');
      }
      
      if (userId == null) {
        throw ServerException('ID de usuario no encontrado en la respuesta.');
      }

      log('🔍 User ID: $userId');
      log('🔍 User Email: $userEmail');
      log('🔍 Backend Role: $backendRole');
      log('🔍 Selected Type: $typeAccount');

      // Paso 3: Validar que el rol del backend coincida con el tipo seleccionado
      final isValidSelection = _validateUserTypeSelection(typeAccount, backendRole);
      
      if (!isValidSelection) {
        log('❌ Login failed: Role mismatch. Backend says "$backendRole", user selected "$typeAccount"');
        
        if (backendRole == 'patient') {
          throw ServerException('Esta cuenta pertenece a un paciente. Por favor, selecciona "Paciente" para iniciar sesión.');
        } else if (backendRole == 'professional') {
          throw ServerException('Esta cuenta pertenece a un especialista. Por favor, selecciona "Especialista" para iniciar sesión.');
        } else {
          throw ServerException('Tipo de cuenta no reconocido. Contacta al administrador.');
        }
      }

      // Paso 4: Crear el modelo de usuario con el tipo correcto
      log('✅ Validation successful: User role matches selected type');
      
      return UserModel.fromLoginResponseWithRole(
        loginJson: responseBody,
        backendRole: backendRole,
      );

    } on ServerException {
      rethrow;
    } catch (e) {
      log('Error in login request: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }

  /// Convierte el tipo seleccionado en la UI al rol del backend
  String _convertTypeAccountToBackendRole(String typeAccount) {
    switch (typeAccount) {
      case 'patient':
        return 'patient';
      case 'specialist':
        return 'professional';
      default:
        return 'patient'; // valor por defecto
    }
  }

  /// Valida que el tipo seleccionado por el usuario coincida con el rol del backend
  bool _validateUserTypeSelection(String selectedType, String backendRole) {
    switch (selectedType) {
      case 'patient':
        return backendRole == 'patient';
      case 'specialist':
        return backendRole == 'professional';
      default:
        return false;
    }
  }

  @override
  Future<void> register(RegisterParams params) async {
    log('📝 REGISTER PATIENT: Starting patient registration process...');
    final url = ApiConfig.patientBaseUrl;
    
    final formattedBirthDate = DateFormat('dd-MM-yyyy').format(params.birthDate);
    final String genderValue = params.gender;

    final body = {
      "name": params.name,
      "lastNameFather": params.lastName,
      "lastNameMother": params.secondLastName ?? '',
      "birthDate": formattedBirthDate,
      "gender": genderValue,
      "phone": params.phoneNumber,
      "professionalId": params.professionalId,
      "email": params.email,
      "password": params.password,
    };

    log('📝 REGISTER PATIENT: Making POST request to: $url');
    log('📝 REGISTER PATIENT: Request body: $body');
    
    try {
      final response = await apiClient.post(url, body);
      log('📝 REGISTER PATIENT: Response status: ${response.statusCode}');
      log('📝 REGISTER PATIENT: Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ REGISTER PATIENT: Patient registration successful');
        return;
      }

      // Manejar errores específicos
      String errorMessage;
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? 'Error desconocido en el registro del paciente';
      } catch (e) {
        errorMessage = 'Error de formato en la respuesta del servidor (${response.statusCode})';
      }
      
      log('❌ REGISTER PATIENT: Registration failed with status ${response.statusCode}: $errorMessage');
      throw ServerException(errorMessage);
      
    } catch (e) {
      if (e is ServerException) rethrow;
      log('💥 REGISTER PATIENT: Unexpected error: $e');
      throw ServerException('Error de conexión al registrar paciente: ${e.toString()}');
    }
  }

  @override
  Future<void> registerSpecialist(RegisterSpecialistParams params) async {
    log('🩺 REGISTER SPECIALIST: Starting specialist registration process...');
    final url = ApiConfig.professionalBaseUrl;
    
    final formattedBirthDate = DateFormat('dd-MM-yyyy').format(params.birthDate);

    final body = {
      "name": params.name,
      "lastNameFather": params.lastName,
      "lastNameMother": params.secondLastName ?? '',
      "birthDate": formattedBirthDate,
      "gender": params.gender,
      "phone": params.phoneNumber,
      "email": params.email,
      "password": params.password,
      "professionName": params.professionName,
      "professionalLicense": params.professionalLicense,
    };

    log('🩺 REGISTER SPECIALIST: Making POST request to: $url');
    log('🩺 REGISTER SPECIALIST: Request body: $body');
    
    try {
      final response = await apiClient.post(url, body);
      log('🩺 REGISTER SPECIALIST: Response status: ${response.statusCode}');
      log('🩺 REGISTER SPECIALIST: Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ REGISTER SPECIALIST: Specialist registration successful');
        return;
      }

      // Manejar errores específicos para especialistas
      String errorMessage;
      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? 'Error desconocido en el registro del especialista';
      } catch (e) {
        errorMessage = 'Error de formato en la respuesta del servidor (${response.statusCode})';
      }
      
      log('❌ REGISTER SPECIALIST: Registration failed with status ${response.statusCode}: $errorMessage');
      throw ServerException(errorMessage);
      
    } catch (e) {
      if (e is ServerException) rethrow;
      log('💥 REGISTER SPECIALIST: Unexpected error: $e');
      throw ServerException('Error de conexión al registrar especialista: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    log('🔒 FORGOT PASSWORD: Simulating password reset for email: $email');
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || !email.contains('@')) {
      throw ServerException('Correo inválido');
    }
  }
}