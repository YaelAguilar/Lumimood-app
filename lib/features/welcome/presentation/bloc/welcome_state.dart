part of 'welcome_bloc.dart';

sealed class WelcomeState {}

final class WelcomeInitial extends WelcomeState {}

final class WelcomeNavigateToRegister extends WelcomeState {}

final class WelcomeNavigateToLogin extends WelcomeState {}