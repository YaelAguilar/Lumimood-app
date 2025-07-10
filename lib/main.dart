import 'package:flutter/material.dart';
import 'core/injection_container.dart' as di;
import 'core/presentation/router.dart';
import 'core/presentation/theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/diary/presentation/bloc/diary_bloc.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/statistics/presentation/bloc/statistics_bloc.dart';
import 'features/tasks/presentation/bloc/tasks_bloc.dart';
import 'features/welcome/presentation/bloc/welcome_bloc.dart';

void setupLegacyDependencies() {
  di.getIt.registerFactory(() => WelcomeBloc());
  di.getIt.registerFactory(() => AuthBloc());
  di.getIt.registerFactory(() => DiaryBloc());
  di.getIt.registerFactory(() => StatisticsBloc());
  di.getIt.registerFactory(() => TasksBloc());
  di.getIt.registerFactory(() => NotesBloc());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  setupLegacyDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumimood',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}