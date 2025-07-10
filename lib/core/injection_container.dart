import 'package:get_it/get_it.dart';

// Authentication Imports
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/forgot_password.dart';
import '../features/authentication/domain/usecases/login_user.dart';
import '../features/authentication/domain/usecases/register_user.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';

// Diary Imports
import '../features/diary/data/datasources/diary_local_datasource.dart';
import '../features/diary/data/repositories/diary_repository_impl.dart';
import '../features/diary/domain/repositories/diary_repository.dart';
import '../features/diary/domain/usecases/get_emotions.dart';
import '../features/diary/domain/usecases/save_diary_entry.dart';
import '../features/diary/presentation/bloc/diary_bloc.dart';

// Notes Imports
import '../features/notes/data/datasources/notes_local_datasource.dart';
import '../features/notes/data/repositories/notes_repository_impl.dart';
import '../features/notes/domain/repositories/notes_repository.dart';
import '../features/notes/domain/usecases/add_note.dart';
import '../features/notes/domain/usecases/get_notes.dart';
import '../features/notes/presentation/bloc/notes_bloc.dart';

// Tasks Imports
import '../features/tasks/data/datasources/tasks_local_datasource.dart';
import '../features/tasks/data/repositories/tasks_repository_impl.dart';
import '../features/tasks/domain/repositories/tasks_repository.dart';
import '../features/tasks/domain/usecases/add_task.dart' as tasks_add;
import '../features/tasks/domain/usecases/get_tasks.dart';
import '../features/tasks/domain/usecases/toggle_task_completion.dart';
import '../features/tasks/presentation/bloc/tasks_bloc.dart';

// Statistics Imports
import '../features/statistics/data/datasources/statistics_remote_datasource.dart';
import '../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../features/statistics/domain/repositories/statistics_repository.dart';
import '../features/statistics/domain/usecases/get_statistics_data.dart';
import '../features/statistics/presentation/bloc/statistics_bloc.dart';

// Welcome Imports
import '../features/welcome/presentation/bloc/welcome_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Features
  _initAuth();
  _initDiary();
  _initNotes();
  _initTasks();
  _initStatistics();
  _initWelcome();
}

void _initAuth() {
  getIt.registerFactory(() => AuthBloc(loginUser: getIt(), registerUser: getIt(), forgotPassword: getIt()));
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => RegisterUser(getIt()));
  getIt.registerLazySingleton(() => ForgotPassword(getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
}

void _initDiary() {
  getIt.registerFactory(() => DiaryBloc(getEmotions: getIt(), saveDiaryEntry: getIt()));
  getIt.registerLazySingleton(() => GetEmotions(getIt()));
  getIt.registerLazySingleton(() => SaveDiaryEntry(getIt()));
  getIt.registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl(localDataSource: getIt()));
  getIt.registerLazySingleton<DiaryLocalDataSource>(() => DiaryLocalDataSourceImpl());
}

void _initNotes() {
  getIt.registerFactory(() => NotesBloc(getNotes: getIt(), addNote: getIt()));
  getIt.registerLazySingleton(() => GetNotes(getIt()));
  getIt.registerLazySingleton(() => AddNote(getIt()));
  getIt.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(localDataSource: getIt()));
  getIt.registerLazySingleton<NotesLocalDataSource>(() => NotesLocalDataSourceImpl());
}

void _initTasks() {
  getIt.registerFactory(() => TasksBloc(getTasks: getIt(), addTask: getIt(), toggleTaskCompletion: getIt()));
  getIt.registerLazySingleton(() => GetTasks(getIt()));
  getIt.registerLazySingleton(() => tasks_add.AddTask(getIt()));
  getIt.registerLazySingleton(() => ToggleTaskCompletion(getIt()));
  getIt.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(localDataSource: getIt()));
  getIt.registerLazySingleton<TasksLocalDataSource>(() => TasksLocalDataSourceImpl());
}

void _initStatistics() {
  getIt.registerFactory(() => StatisticsBloc(getStatisticsData: getIt()));
  getIt.registerLazySingleton(() => GetStatisticsData(getIt()));
  getIt.registerLazySingleton<StatisticsRepository>(() => StatisticsRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<StatisticsRemoteDataSource>(() => StatisticsRemoteDataSourceImpl());
}

void _initWelcome() {
  getIt.registerFactory(() => WelcomeBloc());
}