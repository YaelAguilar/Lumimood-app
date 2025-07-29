import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String name;
  final String lastNameFather;
  final String lastNameMother;
  final DateTime birthDate;
  final String gender;
  final String phone;
  final String email;
  final String professionalId;
  final DateTime? createdAt;

  const PatientEntity({
    required this.id,
    required this.name,
    required this.lastNameFather,
    required this.lastNameMother,
    required this.birthDate,
    required this.gender,
    required this.phone,
    required this.email,
    required this.professionalId,
    this.createdAt,
  });

  String get fullName => '$name $lastNameFather $lastNameMother'.trim();

  @override
  List<Object?> get props => [
        id,
        name,
        lastNameFather,
        lastNameMother,
        birthDate,
        gender,
        phone,
        email,
        professionalId,
        createdAt,
      ];
}