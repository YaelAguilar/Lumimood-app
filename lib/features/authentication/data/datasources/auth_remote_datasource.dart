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
  Future<Map<String, dynamic>?> checkProfessionalByCredentialId(String credentialId);
  Future<Map<String, dynamic>?> checkPatientByCredentialId(String credentialId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password, required String typeAccount}) async {
    log('🚀 AuthRemoteDataSource.login() CALLED - Email: $email, User selected type: $typeAccount');
    
    try {
      // Paso 1: Autenticar siempre contra el servicio de identidad.
      final response = await apiClient.post(
        '${ApiConfig.identityBaseUrl}/login',
        {'email': email, 'password': password, 'typeAccount': typeAccount},
      );

      log('Identity service response status: ${response.statusCode}');
      log('Identity service response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        throw ServerException(errorBody['message'] ?? 'Credenciales inválidas');
      }

      final responseBody = json.decode(response.body);
      final loginResult = responseBody['loginResult'];
      final credentialId = loginResult?['id']?.toString();

      if (credentialId == null) {
        throw ServerException('Respuesta de autenticación inválida del servidor.');
      }

      // Paso 2: Verificar el tipo de cuenta real del usuario
      if (typeAccount == 'patient') {
        log('🔍 User wants to log in as Patient. Verifying user type...');
        
        // Primero verificamos si es un especialista
        final professionalData = await checkProfessionalByCredentialId(credentialId);
        
        if (professionalData != null) {
          // Es un especialista intentando entrar como paciente
          log('❌ Login failed: A registered specialist attempted to log in as a patient.');
          throw ServerException('Esta cuenta pertenece a un especialista. Por favor, selecciona "Especialista" para iniciar sesión.');
        }
        
        // Ahora verificamos si es un paciente
        final patientData = await checkPatientByCredentialId(credentialId);
        
        if (patientData == null) {
          // Las credenciales son válidas pero no está registrado ni como paciente ni como especialista
          log('❌ Login failed: User is not registered as patient.');
          throw ServerException('Esta cuenta no está registrada como paciente.');
        }
        
        // Es un paciente válido
        log('✅ Verification successful: User is a valid patient.');
        return UserModel.fromLoginWithPatient(
          loginJson: responseBody,
          patientJson: patientData,
        );

      } else { // typeAccount == 'specialist'
        log('🔍 User wants to log in as Specialist. Verifying user type...');
        
        // Verificamos si es un especialista
        final professionalData = await checkProfessionalByCredentialId(credentialId);
        
        if (professionalData == null) {
          // Ahora verificamos si es un paciente intentando entrar como especialista
          final patientData = await checkPatientByCredentialId(credentialId);
          
          if (patientData != null) {
            log('❌ Login failed: A registered patient attempted to log in as a specialist.');
            throw ServerException('Esta cuenta pertenece a un paciente. Por favor, selecciona "Paciente" para iniciar sesión.');
          }
          
          // No está registrado en ninguno de los dos
          log('❌ Login failed: User is not a registered specialist.');
          throw ServerException('Esta cuenta no está registrada como especialista.');
        }
        
        // Es un especialista válido
        log('✅ Verification successful: User is a registered specialist.');
        return UserModel.fromLoginWithProfessional(
          loginJson: responseBody,
          professionalJson: professionalData,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      log('Error in login request: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
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

  @override
  Future<Map<String, dynamic>?> checkProfessionalByCredentialId(String credentialId) async {
    log('🔍 Checking professional service for credentialId: $credentialId');
    final url = '${ApiConfig.professionalBaseUrl}/credential/$credentialId';
    log('🌍 Making HTTP request to: $url');
    
    try {
      final response = await apiClient.get(url);
      log('📊 Professional service response status: ${response.statusCode}');
      log('📊 Professional service response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        log('✅ Professional found: $responseBody');
        return responseBody;
      } else if (response.statusCode == 404) {
        log('⚠️ Professional not found for credentialId: $credentialId');
        return null;
      } else {
        log('❌ Unexpected response from professional service: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ Error checking professional service: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> checkPatientByCredentialId(String credentialId) async {
    log('🔍 Checking patient service for credentialId: $credentialId');
    final url = '${ApiConfig.patientBaseUrl}/credential/$credentialId';
    log('🌍 Making HTTP request to: $url');
    
    try {
      final response = await apiClient.get(url);
      log('📊 Patient service response status: ${response.statusCode}');
      log('📊 Patient service response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        log('✅ Patient found: $responseBody');
        return responseBody;
      } else if (response.statusCode == 404) {
        log('⚠️ Patient not found for credentialId: $credentialId');
        return null;
      } else {
        log('❌ Unexpected response from patient service: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ Error checking patient service: $e');
      return null;
    }
  }
}