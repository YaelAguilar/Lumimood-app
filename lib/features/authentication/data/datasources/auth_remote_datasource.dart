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
        // El backend de identidad ignora 'typeAccount', lo cual está bien.
        // Lo enviamos porque la firma del método en ApiClient lo requiere implícitamente, 
        // pero solo usamos 'email' y 'password' para la autenticación real.
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

      // --- LÓGICA CORREGIDA Y MEJORADA ---
      // Paso 2: Verificar el rol del usuario BASADO EN LA SELECCIÓN DE LA UI.
      
      if (typeAccount == 'patient') {
        // El usuario INTENTA iniciar sesión como paciente.
        // Verificamos que esta credencial NO pertenezca a un especialista para evitar que un especialista entre como paciente.
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
      rethrow; // Relanzar excepciones ya manejadas.
    } catch (e) {
      log('Error in login request: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> register(RegisterParams params) async {
    const url = ApiConfig.patientBaseUrl;
    
    final formattedBirthDate = DateFormat('dd-MM-yyyy').format(params.birthDate);
    final String genderValue = params.gender;

    final body = {
      "name": params.name,
      "lastNameFather": params.lastName,
      "lastNameMother": params.secondLastName ?? '',
      "birthDate": formattedBirthDate,
      "gender": genderValue,
      "phone": params.phoneNumber,
      "email": params.email,
      "password": params.password,
    };

    log('Sending registration request with body: $body');
    
    final response = await apiClient.post(url, body);

    if (response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      log('Registration failed with status ${response.statusCode}: ${errorBody['message']}');
      throw ServerException(errorBody['message'] ?? 'Error en el registro');
    }
  }

  @override
  Future<void> registerSpecialist(RegisterSpecialistParams params) async {
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

    log('Sending SPECIALIST registration request to $url with body: $body');
    
    final response = await apiClient.post(url, body);

    if (response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      log('Specialist registration failed with status ${response.statusCode}: ${errorBody['message']}');
      throw ServerException(errorBody['message'] ?? 'Error en el registro del especialista');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    log('API CALL: Simulating password reset for email: $email');
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