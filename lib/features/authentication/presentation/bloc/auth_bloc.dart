import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/register_specialist.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final RegisterSpecialist registerSpecialist;
  final ForgotPassword forgotPassword;
  final SessionCubit sessionCubit;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.registerSpecialist,
    required this.forgotPassword,
    required this.sessionCubit,
  }) : super(const AuthState()) {
    on<AuthViewModeChanged>((event, emit) {
      emit(state.copyWith(
        viewMode: event.viewMode,
        status: FormStatus.initial,
        errorMessage: null,
        successMessage: null,
      ));
    });

    on<AuthEmailChanged>((event, emit) => emit(state.copyWith(email: event.email, status: FormStatus.initial)));
    on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password, status: FormStatus.initial)));
    on<AuthPasswordVisibilityToggled>((event, emit) => emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible)));
    
    // Eventos para datos del paciente
    on<AuthPatientNameChanged>((event, emit) => emit(state.copyWith(patientName: event.name)));
    on<AuthPatientLastNameChanged>((event, emit) => emit(state.copyWith(patientLastName: event.lastName)));
    on<AuthPatientSecondLastNameChanged>((event, emit) => emit(state.copyWith(patientSecondLastName: event.secondLastName)));
    on<AuthPatientGenderChanged>((event, emit) => emit(state.copyWith(patientGender: event.gender)));
    on<AuthPatientBirthDateChanged>((event, emit) => emit(state.copyWith(patientBirthDate: event.birthDate)));
    on<AuthPatientPhoneNumberChanged>((event, emit) => emit(state.copyWith(patientPhoneNumber: event.phoneNumber)));
    on<AuthProfessionalIdChanged>((event, emit) => emit(state.copyWith(professionalId: event.professionalId)));
    
    // Eventos para datos del especialista
    on<AuthSpecialistNameChanged>((event, emit) => emit(state.copyWith(specialistName: event.name)));
    on<AuthSpecialistLastNameChanged>((event, emit) => emit(state.copyWith(specialistLastName: event.lastName)));
    on<AuthSpecialistSecondLastNameChanged>((event, emit) => emit(state.copyWith(specialistSecondLastName: event.secondLastName)));
    on<AuthSpecialistGenderChanged>((event, emit) => emit(state.copyWith(specialistGender: event.gender)));
    on<AuthSpecialistBirthDateChanged>((event, emit) => emit(state.copyWith(specialistBirthDate: event.birthDate)));
    on<AuthSpecialistPhoneNumberChanged>((event, emit) => emit(state.copyWith(specialistPhoneNumber: event.phoneNumber)));
    on<AuthProfessionNameChanged>((event, emit) => emit(state.copyWith(professionName: event.professionName)));
    on<AuthProfessionalLicenseChanged>((event, emit) => emit(state.copyWith(professionalLicense: event.license)));
    
    on<AuthAccountTypeChanged>((event, emit) => emit(state.copyWith(accountType: event.accountType)));
    
    on<AuthLoginWithEmailAndPasswordPressed>(_onLoginWithEmail);
    on<AuthRegisterWithEmailAndPasswordPressed>(_onRegisterWithEmail);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetState>(_onResetState);
  }

  void _onResetState(AuthResetState event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: FormStatus.initial, errorMessage: null, successMessage: null));
  }

  Future<void> _onLoginWithEmail(AuthLoginWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    log('🔑 AUTH BLOC: Login initiated for ${state.email} as ${state.accountType.name}');
    
    if (state.email.trim().isEmpty || state.password.trim().isEmpty) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor completa todos los campos'));
      return;
    }

    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await loginUser(LoginParams(
      email: state.email.trim(),
      password: state.password.trim(),
      typeAccount: state.accountType,
    ));

    result.fold(
      (failure) {
        log('❌ AUTH BLOC: Login failed - ${failure.message}');
        emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message));
      },
      (user) {
        log('✅ AUTH BLOC: Login successful for user ${user.id} (${user.typeAccount.name})');
        emit(state.copyWith(status: FormStatus.success));
        sessionCubit.showSession(user, user.token);
      },
    );
  }
  
  Future<void> _onRegisterWithEmail(AuthRegisterWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    if (state.accountType == AccountType.patient) {
      // Validación específica para pacientes
      if (state.patientBirthDate == null) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, selecciona tu fecha de nacimiento.'));
        return;
      }

      if (state.professionalId.trim().isEmpty) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, ingresa el ID del especialista.'));
        return;
      }

      if (state.patientName.trim().isEmpty || state.patientLastName.trim().isEmpty) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, completa el nombre y apellido paterno.'));
        return;
      }

      final result = await registerUser(RegisterParams(
        name: state.patientName.trim(),
        lastName: state.patientLastName.trim(),
        secondLastName: state.patientSecondLastName.trim().isEmpty ? null : state.patientSecondLastName.trim(),
        email: state.email.trim(),
        password: state.password.trim(),
        gender: state.patientGender,
        phoneNumber: state.patientPhoneNumber.trim(),
        birthDate: state.patientBirthDate!,
        professionalId: state.professionalId.trim(),
      ));
      
      result.fold(
        (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message)),
        (_) => emit(state.copyWith(status: FormStatus.success, successMessage: '¡Registro de paciente exitoso!')),
      );
    } else {
      // Validación específica para especialistas
      if (state.specialistBirthDate == null) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, selecciona tu fecha de nacimiento.'));
        return;
      }

      if (state.specialistName.trim().isEmpty || state.specialistLastName.trim().isEmpty) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, completa el nombre y apellido paterno.'));
        return;
      }

      if (state.professionalLicense.trim().isEmpty) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, ingresa tu cédula profesional.'));
        return;
      }

      final result = await registerSpecialist(RegisterSpecialistParams(
        name: state.specialistName.trim(),
        lastName: state.specialistLastName.trim(),
        secondLastName: state.specialistSecondLastName.trim().isEmpty ? null : state.specialistSecondLastName.trim(),
        email: state.email.trim(),
        password: state.password.trim(),
        gender: state.specialistGender,
        phoneNumber: state.specialistPhoneNumber.trim(),
        birthDate: state.specialistBirthDate!,
        professionName: state.professionName,
        professionalLicense: state.professionalLicense.trim(),
      ));
      
      result.fold(
        (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message)),
        (_) => emit(state.copyWith(status: FormStatus.success, successMessage: '¡Registro de especialista exitoso!')),
      );
    }
  }

  Future<void> _onForgotPasswordRequested(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await forgotPassword(ForgotPasswordParams(email: state.email));

    result.fold(
      (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: FormStatus.success, successMessage: 'Se ha enviado un enlace de recuperación a tu correo.')),
    );
  }
}