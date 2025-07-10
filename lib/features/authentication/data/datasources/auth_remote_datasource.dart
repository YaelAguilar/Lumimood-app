import 'dart:developer';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String lastName,
    String? secondLastName,
    required String email,
    required String password,
    required String gender,
  });
  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({required String email, required String password}) async {
    log('DATA SOURCE: Simulating API call for login with email: $email');
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.length < 6) {
      log('DATA SOURCE: Invalid input.');
      throw ServerException();
    }
    
    return UserModel(id: 'user_123', email: email, name: 'Usuario');
  }

  @override
  Future<UserModel> register({
    required String name,
    required String lastName,
    String? secondLastName,
    required String email,
    required String password,
    required String gender,
  }) async {
    log('DATA SOURCE: Simulating API register call for email: $email');
    await Future.delayed(const Duration(seconds: 2));
    
    if (name.isEmpty || lastName.isEmpty || email.isEmpty || password.length < 6) {
      log('DATA SOURCE: Invalid registration data.');
      throw ServerException();
    }
    
    return UserModel(id: 'user_124', email: email, name: name, lastName: lastName);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    log('DATA SOURCE: Simulating API password reset for email: $email');
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty) {
      throw ServerException();
    }
    return;
  }
}