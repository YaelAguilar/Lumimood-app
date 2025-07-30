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
      // Paso 1: Autenticar contra el servicio de identidad
      final response = await apiClient.post(
        '${ApiConfig.identityBaseUrl}/login/',
        {
          'email': email, 
          'password': password
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

      final userEmail = loginResult['email']?.toString() ?? email;
      
      log('🔍 User Email: $userEmail');

      // Paso 2: Validar el tipo de cuenta real vs el seleccionado usando EMAIL
      if (typeAccount == 'patient') {
        log('🔍 User wants to log in as Patient. Validating...');
        
        // Verificar si existe como paciente
        final patientData = await _checkIfPatientExists(userEmail);
        
        if (patientData != null) {
          // Es realmente un paciente
          log('✅ Validation successful: User is a legitimate patient.');
          return UserModel.fromLoginWithPatient(
            loginJson: responseBody,
            patientJson: patientData,
          );
        } else {
          // No es paciente, verificar si es especialista para dar mensaje específico
          final professionalData = await _checkIfProfessionalExists(userEmail);
          
          if (professionalData != null) {
            log('❌ Login failed: User is a specialist trying to log in as patient.');
            throw ServerException('Esta cuenta pertenece a un especialista. Por favor, selecciona "Especialista" para iniciar sesión.');
          } else {
            log('❌ Login failed: User credentials are valid but not registered as patient.');
            throw ServerException('Esta cuenta no está registrada como paciente.');
          }
        }
        
      } else { // typeAccount == 'specialist'
        log('🔍 User wants to log in as Specialist. Validating...');
        
        // Verificar si existe como especialista
        final professionalData = await _checkIfProfessionalExists(userEmail);
        
        if (professionalData != null) {
          // Es realmente un especialista
          log('✅ Validation successful: User is a legitimate specialist.');
          return UserModel.fromLoginWithProfessional(
            loginJson: responseBody,
            professionalJson: professionalData,
          );
        } else {
          // No es especialista, verificar si es paciente para dar mensaje específico
          final patientData = await _checkIfPatientExists(userEmail);
          
          if (patientData != null) {
            log('❌ Login failed: User is a patient trying to log in as specialist.');
            throw ServerException('Esta cuenta pertenece a un paciente. Por favor, selecciona "Paciente" para iniciar sesión.');
          } else {
            log('❌ Login failed: User credentials are valid but not registered as specialist.');
            throw ServerException('Esta cuenta no está registrada como especialista.');
          }
        }
      }

    } on ServerException {
      rethrow;
    } catch (e) {
      log('Error in login request: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }

  // Método para verificar si un usuario existe como paciente (por email)
  Future<Map<String, dynamic>?> _checkIfPatientExists(String email) async {
    log('🔍 Checking if user exists as patient by email: $email');
    
    try {
      // Intentamos obtener todos los pacientes y buscar por email
      // Según Postman: GET /patient/ (GetAllIdPatient)
      final url = '${ApiConfig.patientBaseUrl}/';
      log('🌍 Making HTTP request to: $url');
      
      final response = await apiClient.get(url);
      log('📊 Patient service response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        log('✅ Patients list retrieved: $responseBody');
        
        // Si la respuesta es una lista, buscar por email
        if (responseBody is List) {
          for (var patient in responseBody) {
            if (patient is Map<String, dynamic> && patient['email'] == email) {
              log('✅ Patient found by email: $patient');
              return patient;
            }
          }
        } else if (responseBody is Map<String, dynamic>) {
          // Si la respuesta es un objeto con una lista dentro
          if (responseBody.containsKey('patients')) {
            final patientsList = responseBody['patients'] as List?;
            if (patientsList != null) {
              for (var patient in patientsList) {
                if (patient is Map<String, dynamic> && patient['email'] == email) {
                  log('✅ Patient found by email: $patient');
                  return patient;
                }
              }
            }
          }
        }
        
        log('⚠️ Patient not found for email: $email');
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

  // Método para verificar si un usuario existe como profesional (por email)
  Future<Map<String, dynamic>?> _checkIfProfessionalExists(String email) async {
    log('🔍 Checking if user exists as professional by email: $email');
    
    try {
      // Según la documentación de Postman, no hay un endpoint para obtener todos los profesionales
      // Pero podemos intentar hacer una búsqueda inteligente
      // Intentamos usar el endpoint que más se parecería
      final url = '${ApiConfig.professionalBaseUrl}/';
      log('🌍 Making HTTP request to: $url');
      
      final response = await apiClient.get(url);
      log('📊 Professional service response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        log('✅ Professional service responded: $responseBody');
        
        // Si la respuesta es una lista, buscar por email
        if (responseBody is List) {
          for (var professional in responseBody) {
            if (professional is Map<String, dynamic> && professional['email'] == email) {
              log('✅ Professional found by email: $professional');
              return professional;
            }
          }
        } else if (responseBody is Map<String, dynamic>) {
          // Si la respuesta es un objeto con una lista dentro
          if (responseBody.containsKey('professionals')) {
            final professionalsList = responseBody['professionals'] as List?;
            if (professionalsList != null) {
              for (var professional in professionalsList) {
                if (professional is Map<String, dynamic> && professional['email'] == email) {
                  log('✅ Professional found by email: $professional');
                  return professional;
                }
              }
            }
          }
        }
        
        log('⚠️ Professional not found for email: $email');
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