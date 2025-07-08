import 'package:get_it/get_it.dart';

import '../features/authentication/presentation/bloc/auth_bloc.dart';

import '../features/diary/presentation/bloc/diary_bloc.dart';
import '../features/welcome/presentation/bloc/welcome_bloc.dart';

final getIt = GetIt.instance;

void setup() {

  getIt.registerFactory(() => WelcomeBloc());
  getIt.registerFactory(() => DiaryBloc());
  
  getIt.registerFactory(() => AuthBloc());

}