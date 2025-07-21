import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    log('🎯 LOGIN USE CASE: Called with email=${params.email}, typeAccount=${params.typeAccount.name}');
    
    final result = await repository.login(
      email: params.email,
      password: params.password,
      typeAccount: params.typeAccount,
    );
    
    log('🎯 LOGIN USE CASE: Repository returned result');
    return result;
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  final AccountType typeAccount;

  const LoginParams({
    required this.email,
    required this.password,
    required this.typeAccount,
  });

  @override
  List<Object?> get props => [email, password, typeAccount];
}