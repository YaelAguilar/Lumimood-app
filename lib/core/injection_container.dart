import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'session/session_cubit.dart';

// Authentication Imports
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/forgot_password.dart';
import '../features/authentication/domain/usecases/login_user.dart';
import '../features/authentication/domain/usecases/register_user.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';

// Diary Imports
import '../features/diary/data/datasources/diary_remote_datasource.dart'; // Corregido para importar remote
import '../features/diary/data/repositories/diary_repository_impl.dart';
import '../features/diary/domain/repositories/diary_repository.dart';
import '../features/diary/domain/usecases/get_emotions.dart';
import '../features/diary/domain/usecases/save_diary_entry.dart';
import '../features/diary/presentation/bloc/diary_bloc.dart';

// Notes Imports
import '../features/notes/data/datasources/notes_remote_datasource.dart'; // Corregido para importar remote
import '../features/notes/data/repositories/notes_repository_impl.dart';
import '../features/notes/domain/repositories/notes_repository.dart';
import '../features/notes/domain/usecases/add_note.dart';
import '../features/notes/domain/usecases/get_notes.dart';
import '../features/notes/presentation/bloc/notes_bloc.dart';

// Tasks Imports (Mantenemos la implementación local por ahora)
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

// Specialist Imports
import '../features/specialist/presentation/bloc/specialist_bloc.dart';
import '../features/specialist/data/datasources/appointment_remote_datasource.dart';
import '../features/specialist/data/repositories/appointment_repository_impl.dart';
import '../features/specialist/domain/repositories/appointment_repository.dart';
import '../features/specialist/domain/usecases/get_appointments_by_professional.dart';


final getIt = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => ApiClient(getIt(), getIt()));
  
  getIt.registerLazySingleton(() => SessionCubit(sharedPreferences: getIt()));

  // Features
  _initAuth();
  _initDiary();
  _initNotes();
  _initTasks();
  _initStatistics();
  _initWelcome();
  _initSpecialist();
}

void _initAuth() {
  getIt.registerFactory(() => AuthBloc(
        loginUser: getIt(),
        registerUser: getIt(),
        forgotPassword: getIt(),
        sessionCubit: getIt(),
      ));
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => RegisterUser(getIt()));
  getIt.registerLazySingleton(() => ForgotPassword(getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: getIt()));
}

void _initDiary() {
  getIt.registerFactory(() => DiaryBloc(getEmotions: getIt(), saveDiaryEntry: getIt(), sessionCubit: getIt()));
  getIt.registerLazySingleton(() => GetEmotions(getIt()));
  getIt.registerLazySingleton(() => SaveDiaryEntry(getIt()));
  getIt.registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<DiaryRemoteDataSource>(() => DiaryRemoteDataSourceImpl(apiClient: getIt()));
}

void _initNotes() {
  getIt.registerFactory(() => NotesBloc(getNotes: getIt(), addNote: getIt(), sessionCubit: getIt()));
  getIt.registerLazySingleton(() => GetNotes(getIt()));
  getIt.registerLazySingleton(() => AddNote(getIt()));
  getIt.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<NotesRemoteDataSource>(() => NotesRemoteDataSourceImpl(apiClient: getIt()));
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
  getIt.registerFactory(() => StatisticsBloc(getStatisticsData: getIt(), sessionCubit: getIt()));
  getIt.registerLazySingleton(() => GetStatisticsData(getIt()));
  getIt.registerLazySingleton<StatisticsRepository>(() => StatisticsRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<StatisticsRemoteDataSource>(() => StatisticsRemoteDataSourceImpl(apiClient: getIt()));
}

void _initWelcome() {
  getIt.registerFactory(() => WelcomeBloc());
}

void _initSpecialist() {
  getIt.registerFactory(() => SpecialistBloc(getAppointments: getIt(), sessionCubit: getIt()));
  getIt.registerLazySingleton(() => GetAppointmentsByProfessional(getIt()));
  getIt.registerLazySingleton<AppointmentRepository>(() => AppointmentRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(() => AppointmentRemoteDataSourceImpl(apiClient: getIt()));
}