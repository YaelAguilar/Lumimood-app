part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthViewModeChanged extends AuthEvent {
  final AuthViewMode viewMode;
  AuthViewModeChanged(this.viewMode);
}

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

final class AuthProfessionNameChanged extends AuthEvent {
  final String professionName;
  AuthProfessionNameChanged(this.professionName);
}

final class AuthProfessionalLicenseChanged extends AuthEvent {
  final String license;
  AuthProfessionalLicenseChanged(this.license);
}

final class AuthProfessionalIdChanged extends AuthEvent {
  final String professionalId;
  AuthProfessionalIdChanged(this.professionalId);
}