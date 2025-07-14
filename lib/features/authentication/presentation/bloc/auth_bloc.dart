import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final ForgotPassword forgotPassword;
  final SessionCubit sessionCubit;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.forgotPassword,
    required this.sessionCubit,
  }) : super(const AuthState()) {
    on<AuthEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
    on<AuthPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<AuthPasswordVisibilityToggled>((event, emit) => emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible)));
    on<AuthNameChanged>((event, emit) => emit(state.copyWith(name: event.name)));
    on<AuthLastNameChanged>((event, emit) => emit(state.copyWith(lastName: event.lastName)));
    on<AuthSecondLastNameChanged>((event, emit) => emit(state.copyWith(secondLastName: event.secondLastName)));
    on<AuthGenderChanged>((event, emit) => emit(state.copyWith(gender: event.gender)));
    on<AuthBirthDateChanged>((event, emit) => emit(state.copyWith(birthDate: event.birthDate)));
    on<AuthPhoneNumberChanged>((event, emit) => emit(state.copyWith(phoneNumber: event.phoneNumber)));
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
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await loginUser(LoginParams(
      email: state.email,
      password: state.password,
      typeAccount: state.accountType,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message));
        // Solo resetea en caso de error después de un pequeño delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isClosed) {
            emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
          }
        });
      },
      (user) {
        sessionCubit.showSession(user, user.token);
        emit(state.copyWith(status: FormStatus.success));
        // No resetea inmediatamente el estado exitoso para permitir la navegación
      },
    );
  }
  
  Future<void> _onRegisterWithEmail(AuthRegisterWithEmailAndPasswordPressed event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    if (state.birthDate == null) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: 'Por favor, selecciona tu fecha de nacimiento.'));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
        }
      });
      return;
    }

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
      (failure) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message));
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isClosed) {
            emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
          }
        });
      },
      (_) => emit(state.copyWith(status: FormStatus.success, successMessage: '¡Registro exitoso! Ahora puedes iniciar sesión.')),
    );
  }

  Future<void> _onForgotPasswordRequested(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: FormStatus.loading, errorMessage: null));

    final result = await forgotPassword(ForgotPasswordParams(email: state.email));

    result.fold(
      (failure) {
        emit(state.copyWith(status: FormStatus.error, errorMessage: failure.message));
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isClosed) {
            emit(state.copyWith(status: FormStatus.initial, errorMessage: null));
          }
        });
      },
      (_) => emit(state.copyWith(status: FormStatus.success, successMessage: 'Se ha enviado un enlace de recuperación a tu correo.')),
    );
  }
}