import 'package:get_it/get_it.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/diary/presentation/bloc/diary_bloc.dart';
import '../features/notes/presentation/bloc/notes_bloc.dart';
import '../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../features/tasks/presentation/bloc/tasks_bloc.dart';
import '../features/welcome/presentation/bloc/welcome_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerFactory(() => WelcomeBloc());
  getIt.registerFactory(() => AuthBloc());
  getIt.registerFactory(() => DiaryBloc());
  getIt.registerFactory(() => StatisticsBloc());
  getIt.registerFactory(() => TasksBloc());
  getIt.registerFactory(() => NotesBloc());
}