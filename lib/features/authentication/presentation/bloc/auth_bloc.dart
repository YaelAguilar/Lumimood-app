import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
    on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<AuthPasswordVisibilityToggled>((event, emit) => emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible)));
    on<AuthLoginWithGooglePressed>(_onLoginWithGoogle);
    on<AuthLoginWithEmailAndPasswordPressed>(_onLoginWithEmail);
    
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    
    on<AuthNameChanged>((event, emit) => emit(state.copyWith(name: event.name)));
    on<AuthLastNameChanged>((event, emit) => emit(state.copyWith(lastName: event.lastName)));
    on<AuthSecondLastNameChanged>((event, emit) => emit(state.copyWith(secondLastName: event.secondLastName)));
    on<AuthGenderChanged>((event, emit) => emit(state.copyWith(gender: event.gender)));
    on<AuthRegisterWithEmailAndPasswordPressed>(_onRegisterWithEmail);
  }

  Future<void> _onForgotPasswordRequested(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));
    log('Requesting password reset for email: ${state.email}');
    
    if (state.email.isEmpty) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, ingresa tu correo.'));
      emit(state.copyWith(status: FormStatus.initial));
      return;
    }

    await Future.delayed(const Duration(seconds: 2));

    log('Password reset email sent successfully.');
    emit(state.copyWith(status: FormStatus.success));
    emit(state.copyWith(status: FormStatus.initial));
  }

  Future<void> _onLoginWithEmail(AuthLoginWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));
    log('Attempting login with email: ${state.email}');
    await Future.delayed(const Duration(seconds: 2));

    if (state.email == "test@test.com" && state.password == "password") {
      emit(state.copyWith(status: FormStatus.success));
    } else {
      emit(state.copyWith(status: FormStatus.error, errorMessage: 'Credenciales inválidas.'));
    }
    emit(state.copyWith(status: FormStatus.initial));
  }
  
  Future<void> _onRegisterWithEmail(AuthRegisterWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));
    log('Attempting to register user: ${state.email}');
    
    if (state.name.isEmpty || state.lastName.isEmpty || state.email.isEmpty || state.password.length < 6) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, completa todos los campos requeridos. La contraseña debe tener al menos 6 caracteres.'));
      emit(state.copyWith(status: FormStatus.initial));
      return;
    }
    
    await Future.delayed(const Duration(seconds: 2));
    log('Registration successful for ${state.email}');
    emit(state.copyWith(status: FormStatus.success));
  }

  Future<void> _onLoginWithGoogle(AuthLoginWithGooglePressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));
    log('Attempting login with Google...');
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(status: FormStatus.success));
  }
}