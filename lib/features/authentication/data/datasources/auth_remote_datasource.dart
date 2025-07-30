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
      // Paso 1: Autenticar contra el servicio de identidad (SIN typeAccount según Postman)
      final response = await apiClient.post(
        '${ApiConfig.identityBaseUrl}/login',
        {
          'email': email, 
          'password': password
          // NO enviamos typeAccount - según Postman no es necesario
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
      
      if (loginResult == null) {
        throw ServerException('Respuesta de autenticación inválida del servidor.');
      }

      // Extraer información del usuario del loginResult
      final userEmail = loginResult['email']?.toString() ?? email;
      final userName = loginResult['name']?.toString() ?? 'Usuario';
      final userId = loginResult['id']?.toString();
      
      if (userId == null) {
        throw ServerException('ID de usuario no encontrado en la respuesta.');
      }

      log('🔍 User ID obtenido: $userId');
      log('🔍 User Email: $userEmail');
      log('🔍 User Name: $userName');

      // Paso 2: Según la documentación de Postman, los servicios no tienen endpoint /credential/{id}
      // Simplemente devolvemos el usuario con el tipo seleccionado
      // El token viene en la respuesta del servicio de identidad
      final token = responseBody['token']?.toString();
      
      if (token == null) {
        throw ServerException('Token no encontrado en la respuesta.');
      }

      // Crear el modelo de usuario según el tipo seleccionado
      if (typeAccount == 'patient') {
        log('✅ Creating patient user model');
        return UserModel.fromLoginResponse(
          loginJson: responseBody,
          userType: 'patient',
        );
      } else {
        log('✅ Creating specialist user model');
        return UserModel.fromLoginResponse(
          loginJson: responseBody,
          userType: 'specialist',
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
}