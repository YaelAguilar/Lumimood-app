import 'package:get_it/get_it.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/forgot_password.dart';
import '../features/authentication/domain/usecases/login_user.dart';
import '../features/authentication/domain/usecases/register_user.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/diary/data/datasources/diary_local_datasource.dart';
import '../features/diary/data/repositories/diary_repository_impl.dart';
import '../features/diary/domain/repositories/diary_repository.dart';
import '../features/diary/domain/usecases/get_emotions.dart';
import '../features/diary/domain/usecases/save_diary_entry.dart';
import '../features/diary/presentation/bloc/diary_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Features
  _initAuth();
  _initDiary();
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