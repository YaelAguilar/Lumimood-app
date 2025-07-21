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
    on<AuthNameChanged>((event, emit) => emit(state.copyWith(name: event.name)));
    on<AuthLastNameChanged>((event, emit) => emit(state.copyWith(lastName: event.lastName)));
    on<AuthSecondLastNameChanged>((event, emit) => emit(state.copyWith(secondLastName: event.secondLastName)));
    on<AuthGenderChanged>((event, emit) => emit(state.copyWith(gender: event.gender)));
    on<AuthBirthDateChanged>((event, emit) => emit(state.copyWith(birthDate: event.birthDate)));
    on<AuthPhoneNumberChanged>((event, emit) => emit(state.copyWith(phoneNumber: event.phoneNumber)));
    on<AuthAccountTypeChanged>((event, emit) => emit(state.copyWith(accountType: event.accountType)));
    on<AuthProfessionNameChanged>((event, emit) => emit(state.copyWith(professionName: event.professionName)));
    on<AuthProfessionalLicenseChanged>((event, emit) => emit(state.copyWith(professionalLicense: event.license)));
    
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
        log('✅ AUTH BLOC: Login successful for user ${user.id}');
        sessionCubit.showSession(user, user.token);
      },
    );
  }
  
  Future<void> _onRegisterWithEmail(AuthRegisterWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    if (state.birthDate == null) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, selecciona tu fecha de nacimiento.'));
      return;
    }

    if (state.accountType == AccountType.patient) {
      final result = await registerUser(RegisterParams(
        name: state.name,
        lastName: state.lastName,
        secondLastName: state.secondLastName,
        email: state.email,
        password: state.password,
        gender: state.gender,
        phoneNumber: state.phoneNumber,
        birthDate: state.birthDate!,
      ));
      result.fold(
        (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message)),
        (_) => emit(state.copyWith(status: FormStatus.success, successMessage: '¡Registro de paciente exitoso!')),
      );
    } else {
      final result = await registerSpecialist(RegisterSpecialistParams(
        name: state.name,
        lastName: state.lastName,
        secondLastName: state.secondLastName,
        email: state.email,
        password: state.password,
        gender: state.gender,
        phoneNumber: state.phoneNumber,
        birthDate: state.birthDate!,
        professionName: state.professionName,
        professionalLicense: state.professionalLicense,
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