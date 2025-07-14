part of 'auth_bloc.dart';

enum FormStatus { initial, loading, success, error }

class AuthState extends Equatable {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final FormStatus status;
  final String? errorMessage;
  final String? successMessage;

  // Campos de registro
  final String name;
  final String lastName;
  final String secondLastName;
  final String gender;
  final DateTime? birthDate;
  final String phoneNumber;
  final AccountType accountType;

  const AuthState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.name = '',
    this.lastName = '',
    this.secondLastName = '',
    this.gender = 'Masculino', // Valor por defecto que coincide con el backend
    this.birthDate,
    this.phoneNumber = '',
    this.accountType = AccountType.patient,
  });

  AuthState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    FormStatus? status,
    String? errorMessage,
    String? successMessage,
    String? name,
    String? lastName,
    String? secondLastName,
    String? gender,
    DateTime? birthDate,
    String? phoneNumber,
    AccountType? accountType,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      accountType: accountType ?? this.accountType,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordVisible,
        status,
        errorMessage,
        successMessage,
        name,
        lastName,
        secondLastName,
        gender,
        birthDate,
        phoneNumber,
        accountType,
      ];
}