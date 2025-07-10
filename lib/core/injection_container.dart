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

final getIt = GetIt.instance;

Future<void> init() async {
  // Features
  _initAuth();
  _initDiary();
  _initNotes();
  _initTasks();
}

void _initAuth() {
  // BLoC
  getIt.registerFactory(
    () => AuthBloc(
      loginUser: getIt(),
      registerUser: getIt(),
      forgotPassword: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => RegisterUser(getIt()));
  getIt.registerLazySingleton(() => ForgotPassword(getIt()));

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
}

void _initDiary() {
  // BLoC
  getIt.registerFactory(
    () => DiaryBloc(
      getEmotions: getIt(),
      saveDiaryEntry: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetEmotions(getIt()));
  getIt.registerLazySingleton(() => SaveDiaryEntry(getIt()));

  // Repository
  getIt.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryImpl(localDataSource: getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton<DiaryLocalDataSource>(
    () => DiaryLocalDataSourceImpl(),
  );
}

void _initNotes() {
  // BLoC
  getIt.registerFactory(
    () => NotesBloc(
      getNotes: getIt(),
      addNote: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetNotes(getIt()));
  getIt.registerLazySingleton(() => AddNote(getIt()));

  // Repository
  getIt.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(localDataSource: getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton<NotesLocalDataSource>(
    () => NotesLocalDataSourceImpl(),
  );
}

void _initTasks() {
  // BLoC
  getIt.registerFactory(
    () => TasksBloc(
      getTasks: getIt(),
      addTask: getIt(),
      toggleTaskCompletion: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetTasks(getIt()));
  getIt.registerLazySingleton(() => tasks_add.AddTask(getIt()));
  getIt.registerLazySingleton(() => ToggleTaskCompletion(getIt()));

  // Repository
  getIt.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(localDataSource: getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton<TasksLocalDataSource>(
    () => TasksLocalDataSourceImpl(),
  );
}