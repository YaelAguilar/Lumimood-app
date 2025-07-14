part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthEmailChanged extends AuthEvent {
  final String email;
  AuthEmailChanged(this.email);
}

final class AuthPasswordChanged extends AuthEvent {
  final String password;
  AuthPasswordChanged(this.password);
}

final class AuthPasswordVisibilityToggled extends AuthEvent {}

final class AuthLoginWithEmailAndPasswordPressed extends AuthEvent {}

final class AuthForgotPasswordRequested extends AuthEvent {}

final class AuthNameChanged extends AuthEvent {
  final String name;
  AuthNameChanged(this.name);
}

final class AuthLastNameChanged extends AuthEvent {
  final String lastName;
  AuthLastNameChanged(this.lastName);
}

final class AuthSecondLastNameChanged extends AuthEvent {
  final String secondLastName;
  AuthSecondLastNameChanged(this.secondLastName);
}

final class AuthGenderChanged extends AuthEvent {
  final String gender;
  AuthGenderChanged(this.gender);
}

final class AuthBirthDateChanged extends AuthEvent {
  final DateTime birthDate;
  AuthBirthDateChanged(this.birthDate);
}

final class AuthPhoneNumberChanged extends AuthEvent {
  final String phoneNumber;
  AuthPhoneNumberChanged(this.phoneNumber);
}

final class AuthAccountTypeChanged extends AuthEvent {
  final AccountType accountType;
  AuthAccountTypeChanged(this.accountType);
}

final class AuthRegisterWithEmailAndPasswordPressed extends AuthEvent {}

final class AuthResetState extends AuthEvent {}