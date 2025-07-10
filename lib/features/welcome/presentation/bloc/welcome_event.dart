part of 'welcome_bloc.dart';

sealed class WelcomeEvent {}

final class RegisterButtonPressed extends WelcomeEvent {}

final class LoginButtonPressed extends WelcomeEvent {}