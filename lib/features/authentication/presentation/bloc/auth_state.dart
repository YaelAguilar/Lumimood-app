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
  
  // Datos específicos del paciente
  final String patientName;
  final String patientLastName;
  final String patientSecondLastName;
  final String patientGender;
  final DateTime? patientBirthDate;
  final String patientPhoneNumber;
  final String professionalId;
  
  // Datos específicos del especialista
  final String specialistName;
  final String specialistLastName;
  final String specialistSecondLastName;
  final String specialistGender;
  final DateTime? specialistBirthDate;
  final String specialistPhoneNumber;
  final String professionName;
  final String professionalLicense;
  
  final AccountType accountType;

  const AuthState({
    this.viewMode = AuthViewMode.login,
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.successMessage,
    // Datos del paciente
    this.patientName = '',
    this.patientLastName = '',
    this.patientSecondLastName = '',
    this.patientGender = 'Masculino',
    this.patientBirthDate,
    this.patientPhoneNumber = '',
    this.professionalId = '',
    // Datos del especialista
    this.specialistName = '',
    this.specialistLastName = '',
    this.specialistSecondLastName = '',
    this.specialistGender = 'Masculino',
    this.specialistBirthDate,
    this.specialistPhoneNumber = '',
    this.professionName = 'psicologo',
    this.professionalLicense = '',
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
    // Datos del paciente
    String? patientName,
    String? patientLastName,
    String? patientSecondLastName,
    String? patientGender,
    DateTime? patientBirthDate,
    String? patientPhoneNumber,
    String? professionalId,
    // Datos del especialista
    String? specialistName,
    String? specialistLastName,
    String? specialistSecondLastName,
    String? specialistGender,
    DateTime? specialistBirthDate,
    String? specialistPhoneNumber,
    String? professionName,
    String? professionalLicense,
    AccountType? accountType,
  }) {
    return AuthState(
      viewMode: viewMode ?? this.viewMode,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      // Datos del paciente
      patientName: patientName ?? this.patientName,
      patientLastName: patientLastName ?? this.patientLastName,
      patientSecondLastName: patientSecondLastName ?? this.patientSecondLastName,
      patientGender: patientGender ?? this.patientGender,
      patientBirthDate: patientBirthDate ?? this.patientBirthDate,
      patientPhoneNumber: patientPhoneNumber ?? this.patientPhoneNumber,
      professionalId: professionalId ?? this.professionalId,
      // Datos del especialista
      specialistName: specialistName ?? this.specialistName,
      specialistLastName: specialistLastName ?? this.specialistLastName,
      specialistSecondLastName: specialistSecondLastName ?? this.specialistSecondLastName,
      specialistGender: specialistGender ?? this.specialistGender,
      specialistBirthDate: specialistBirthDate ?? this.specialistBirthDate,
      specialistPhoneNumber: specialistPhoneNumber ?? this.specialistPhoneNumber,
      professionName: professionName ?? this.professionName,
      professionalLicense: professionalLicense ?? this.professionalLicense,
      accountType: accountType ?? this.accountType,
    );
  }

  @override
  List<Object?> get props => [
        viewMode, email, password, isPasswordVisible, status, errorMessage,
        successMessage, 
        // Datos del paciente
        patientName, patientLastName, patientSecondLastName, patientGender, 
        patientBirthDate, patientPhoneNumber, professionalId,
        // Datos del especialista
        specialistName, specialistLastName, specialistSecondLastName, specialistGender,
        specialistBirthDate, specialistPhoneNumber, professionName, professionalLicense,
        accountType,
      ];
}