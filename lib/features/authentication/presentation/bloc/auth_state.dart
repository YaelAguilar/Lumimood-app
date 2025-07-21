part of 'auth_bloc.dart';

enum FormStatus { initial, loading, success, error }

enum AuthViewMode { login, register, forgotPassword }

class AuthState extends Equatable {
  final AuthViewMode viewMode;

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
    this.viewMode = AuthViewMode.login, // El valor inicial es la vista de login
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.name = '',
    this.lastName = '',
    this.secondLastName = '',
    this.gender = 'Masculino',
    this.birthDate,
    this.phoneNumber = '',
    this.accountType = AccountType.patient,
  });

  AuthState copyWith({
    AuthViewMode? viewMode,
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
      viewMode: viewMode ?? this.viewMode,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      // Usar 'null' explícitamente si no se provee un valor para poder limpiar los mensajes
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
        viewMode,
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