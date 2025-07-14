part of 'auth_bloc.dart';

enum FormStatus { initial, loading, success, error }
enum AccountType { patient, specialist }

class AuthState extends Equatable {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final FormStatus status;
  final String? errorMessage;

  final String name;
  final String lastName;
  final String secondLastName;
  final String gender;
  final String phoneNumber;
  final AccountType accountType;

  const AuthState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.name = '',
    this.lastName = '',
    this.secondLastName = '',
    this.gender = 'Hombre',
    this.phoneNumber = '',
    this.accountType = AccountType.patient,
  });

  AuthState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    FormStatus? status,
    String? errorMessage,
    String? name,
    String? lastName,
    String? secondLastName,
    String? gender,
    String? phoneNumber,
    AccountType? accountType,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      errorMessage: errorMessage,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      gender: gender ?? this.gender,
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
        name,
        lastName,
        secondLastName,
        gender,
        phoneNumber,
        accountType,
      ];
}