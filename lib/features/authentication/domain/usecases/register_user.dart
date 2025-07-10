import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await repository.register(
      name: params.name,
      lastName: params.lastName,
      secondLastName: params.secondLastName,
      email: params.email,
      password: params.password,
      gender: params.gender,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String lastName;
  final String? secondLastName;
  final String email;
  final String password;
  final String gender;

  const RegisterParams({
    required this.name,
    required this.lastName,
    this.secondLastName,
    required this.email,
    required this.password,
    required this.gender,
  });

  @override
  List<Object?> get props => [name, lastName, secondLastName, email, password, gender];
}