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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password, required String typeAccount}) async {
    log('Making login request - Email: $email, TypeAccount: $typeAccount');
    
    try {
      final response = await apiClient.post(
        '${ApiConfig.identityBaseUrl}/login',
        {'email': email, 'password': password, 'typeAccount': typeAccount},
      );

      log('Login response status: ${response.statusCode}');
      log('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        log('Parsed response body: $responseBody');
        return UserModel.fromJson(responseBody);
      } else {
        final errorBody = json.decode(response.body);
        log('Login failed: ${errorBody['message']}');
        throw ServerException(errorBody['message'] ?? 'Error de autenticación');
      }
    } catch (e) {
      log('Error in login request: $e');
      // Si hay un error de conexión o parsing, lanzamos una excepción apropiada
      if (e is ServerException) {
        rethrow;
      } else {
        throw ServerException('Error de conexión: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> register(RegisterParams params) async {
    const url = ApiConfig.patientBaseUrl;
    
    final formattedBirthDate = DateFormat('dd-MM-yyyy').format(params.birthDate);

    // El valor de 'gender' ahora se envía directamente, ya que la UI y el BLoC
    // manejarán los valores exactos que el backend espera ('Masculino', 'Femenino', 'Otro').
    final String genderValue = params.gender;

    final body = {
      "name": params.name,
      "lastNameFather": params.lastName,
      "lastNameMother": params.secondLastName ?? '',
      "birthDate": formattedBirthDate,
      "gender": genderValue, // Usamos el valor directamente
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
    // Simulado, ya que no hay endpoint en la API para esto.
    log('API CALL: Simulating password reset for email: $email');
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || !email.contains('@')) {
      throw ServerException('Correo inválido');
    }
  }
}