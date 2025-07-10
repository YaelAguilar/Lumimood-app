import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final ForgotPassword forgotPassword;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.forgotPassword,
  }) : super(const AuthState()) {
    on<AuthEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
    on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<AuthPasswordVisibilityToggled>((event, emit) => emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible)));
    on<AuthNameChanged>((event, emit) => emit(state.copyWith(name: event.name)));
    on<AuthLastNameChanged>((event, emit) => emit(state.copyWith(lastName: event.lastName)));
    on<AuthSecondLastNameChanged>((event, emit) => emit(state.copyWith(secondLastName: event.secondLastName)));
    on<AuthGenderChanged>((event, emit) => emit(state.copyWith(gender: event.gender)));
    
    on<AuthLoginWithEmailAndPasswordPressed>(_onLoginWithEmail);
    on<AuthRegisterWithEmailAndPasswordPressed>(_onRegisterWithEmail);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onLoginWithEmail(AuthLoginWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await loginUser(LoginParams(email: state.email, password: state.password));

    result.fold(
      (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: 'Credenciales inválidas.')),
      (user) => emit(state.copyWith(status: FormStatus.success)),
    );
    emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
  }
  
  Future<void> _onRegisterWithEmail(AuthRegisterWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await registerUser(RegisterParams(
      name: state.name,
      lastName: state.lastName,
      secondLastName: state.secondLastName,
      email: state.email,
      password: state.password,
      gender: state.gender,
    ));

    result.fold(
      (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, completa todos los campos requeridos. La contraseña debe tener al menos 6 caracteres.')),
      (user) => emit(state.copyWith(status: FormStatus.success)),
    );
    emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
  }

  Future<void> _onForgotPasswordRequested(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await forgotPassword(ForgotPasswordParams(email: state.email));

    result.fold(
      (failure) => emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, ingresa un correo válido.')),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
    emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
  }
}