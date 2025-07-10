import 'package:flutter_bloc/flutter_bloc.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(WelcomeInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  void _onRegisterButtonPressed(RegisterButtonPressed event, Emitter<WelcomeState> emit) {
    emit(WelcomeNavigateToRegister());
  }

  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<WelcomeState> emit) {
    emit(WelcomeNavigateToLogin());
  }
}