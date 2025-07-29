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

// Eventos específicos para datos del paciente
final class AuthPatientNameChanged extends AuthEvent {
  final String name;
  AuthPatientNameChanged(this.name);
}

final class AuthPatientLastNameChanged extends AuthEvent {
  final String lastName;
  AuthPatientLastNameChanged(this.lastName);
}

final class AuthPatientSecondLastNameChanged extends AuthEvent {
  final String secondLastName;
  AuthPatientSecondLastNameChanged(this.secondLastName);
}

final class AuthPatientGenderChanged extends AuthEvent {
  final String gender;
  AuthPatientGenderChanged(this.gender);
}

final class AuthPatientBirthDateChanged extends AuthEvent {
  final DateTime birthDate;
  AuthPatientBirthDateChanged(this.birthDate);
}

final class AuthPatientPhoneNumberChanged extends AuthEvent {
  final String phoneNumber;
  AuthPatientPhoneNumberChanged(this.phoneNumber);
}

// Eventos específicos para datos del especialista
final class AuthSpecialistNameChanged extends AuthEvent {
  final String name;
  AuthSpecialistNameChanged(this.name);
}

final class AuthSpecialistLastNameChanged extends AuthEvent {
  final String lastName;
  AuthSpecialistLastNameChanged(this.lastName);
}

final class AuthSpecialistSecondLastNameChanged extends AuthEvent {
  final String secondLastName;
  AuthSpecialistSecondLastNameChanged(this.secondLastName);
}

final class AuthSpecialistGenderChanged extends AuthEvent {
  final String gender;
  AuthSpecialistGenderChanged(this.gender);
}

final class AuthSpecialistBirthDateChanged extends AuthEvent {
  final DateTime birthDate;
  AuthSpecialistBirthDateChanged(this.birthDate);
}

final class AuthSpecialistPhoneNumberChanged extends AuthEvent {
  final String phoneNumber;
  AuthSpecialistPhoneNumberChanged(this.phoneNumber);
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