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

      if (typeAccount == 'patient') {
        log('🔍 User wants to log in as Patient. Verifying they are NOT a specialist...');
        final professionalData = await checkProfessionalByCredentialId(credentialId);

        if (professionalData != null) {
          // ¡Error! Este usuario es un especialista intentando entrar como paciente.
          log('❌ Login failed: A registered specialist attempted to log in as a patient.');
          throw ServerException('Credenciales incorrectas. Este usuario es un especialista.');
        }

        // Si no es un especialista, procedemos con el login de paciente.
        log('✅ Verification successful: User is not a specialist. Logging in as patient.');
        return UserModel.fromLoginWithProfessional(
          loginJson: responseBody,
          professionalJson: null, // Forzamos a que el tipo de cuenta sea 'patient'.
        );

      } else { // typeAccount == 'specialist'
        // El usuario INTENTA iniciar sesión como especialista. DEBEMOS verificarlo.
        log('🔍 User wants to log in as Specialist. Verifying against professional service...');
        final professionalData = await checkProfessionalByCredentialId(credentialId);

        if (professionalData == null) {
          // La credencial es válida, pero este usuario NO es un especialista.
          log('❌ Login failed: A user with valid credentials is not a registered specialist.');
          throw ServerException('Este usuario no está registrado como especialista.');
        }

        // Si encontramos los datos del especialista, procedemos con el login.
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
      throw ServerException('Error al registrar paciente: $errorMessage');
      
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
      throw ServerException('Error al registrar especialista: $errorMessage');
      
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
      } else {
        log('⚠️ Professional not found (or error) for credentialId: $credentialId. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ Error checking professional service: $e');
      return null;
    }
  }
}