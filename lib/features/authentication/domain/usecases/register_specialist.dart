import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterSpecialist implements UseCase<void, RegisterSpecialistParams> {
  final AuthRepository repository;

  RegisterSpecialist(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterSpecialistParams params) async {
    return await repository.registerSpecialist(params);
  }
}

class RegisterSpecialistParams extends Equatable {
  final String name;
  final String lastName;
  final String? secondLastName;
  final DateTime birthDate;
  final String email;
  final String password;
  final String gender;
  final String phoneNumber;
  final String professionName;
  final String professionalLicense;

  const RegisterSpecialistParams({
    required this.name,
    required this.lastName,
    this.secondLastName,
    required this.birthDate,
    required this.email,
    required this.password,
    required this.gender,
    required this.phoneNumber,
    required this.professionName,
    required this.professionalLicense,
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
        professionName,
        professionalLicense,
      ];
}