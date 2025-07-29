import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<void, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) async {
    return await repository.register(params);
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String lastName;
  final String? secondLastName;
  final DateTime birthDate;
  final String email;
  final String password;
  final String gender;
  final String phoneNumber;
  final String professionalId; // Nuevo campo requerido

  const RegisterParams({
    required this.name,
    required this.lastName,
    this.secondLastName,
    required this.birthDate,
    required this.email,
    required this.password,
    required this.gender,
    required this.phoneNumber,
    required this.professionalId, // Nuevo campo requerido
  });

  @override
  List<Object?> get props => [
        name,
        lastName,
        secondLastName,
        birthDate,
        email,
        password,
        gender,
        phoneNumber,
        professionalId, // Incluir en props
      ];
}