import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/usecases/register_user.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password, required String typeAccount});
  Future<void> register(RegisterParams params);
  Future<void> forgotPassword({required String email});
  Future<Map<String, dynamic>?> checkProfessionalByCredentialId(String credentialId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password, required String typeAccount}) async {
    log('🚀 AuthRemoteDataSource.login() CALLED - Email: $email, TypeAccount: $typeAccount');
    log('🌍 Making HTTP request to: ${ApiConfig.identityBaseUrl}/login');
    
    try {
      final response = await apiClient.post(
        '${ApiConfig.identityBaseUrl}/login',
        {'email': email, 'password': password, 'typeAccount': typeAccount},
      );

      log('Login response status: ${response.statusCode}');
      log('Login response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        log('Login failed: ${errorBody['message']}');
        throw ServerException(errorBody['message'] ?? 'Error de autenticación');
      }

      final responseBody = json.decode(response.body);
      log('Parsed response body: $responseBody');
        
      final loginResult = responseBody['loginResult'];
      final credentialId = loginResult?['id']?.toString();

      if (credentialId == null) {
        log('⚠️ No credentialId found in login response, using fallback JSON parsing.');
        return UserModel.fromJson(responseBody);
      }
      
      log('🔍 Checking if user is a professional with credentialId: $credentialId');
      final professionalData = await checkProfessionalByCredentialId(credentialId);
          
      return UserModel.fromLoginWithProfessional(
        loginJson: responseBody,
        professionalJson: professionalData,
      );
    } on ServerException {
      rethrow; // Relanzar excepciones ya manejadas para que el repositorio las atrape.
    } catch (e) {
      log('Error in login request: $e');
      // Atrapar errores generales (de conexión, parsing, etc.) y encapsularlos.
      throw ServerException('Error de conexión o al procesar la respuesta: ${e.toString()}');
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
    log('🌍 Making HTTP request to: ${ApiConfig.professionalBaseUrl}/credential/$credentialId');
    
    try {
      final response = await apiClient.get('${ApiConfig.professionalBaseUrl}/credential/$credentialId');
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