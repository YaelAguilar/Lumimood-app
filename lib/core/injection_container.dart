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
import '../features/authentication/domain/usecases/register_specialist.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';

// Diary Imports
import '../features/diary/data/datasources/diary_remote_datasource.dart';
import '../features/diary/data/repositories/diary_repository_impl.dart';
import '../features/diary/domain/repositories/diary_repository.dart';
import '../features/diary/domain/usecases/get_emotions.dart';
import '../features/diary/domain/usecases/save_emotion.dart';
import '../features/diary/presentation/bloc/diary_bloc.dart';

// Notes Imports
import '../features/notes/data/datasources/notes_remote_datasource.dart';
import '../features/notes/data/repositories/notes_repository_impl.dart';
import '../features/notes/domain/repositories/notes_repository.dart';
import '../features/notes/domain/usecases/add_note.dart';
import '../features/notes/domain/usecases/get_notes.dart';
import '../features/notes/domain/usecases/update_note.dart';
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

// Specialist Dashboard Imports
import '../features/specialistdashboard/presentation/bloc/specialistdashboard_bloc.dart';
import '../features/specialistdashboard/data/datasources/appointment_remote_datasource.dart';
import '../features/specialistdashboard/data/repositories/appointment_repository_impl.dart';
import '../features/specialistdashboard/domain/repositories/appointment_repository.dart';
import '../features/specialistdashboard/domain/usecases/get_appointments_by_professional.dart';

// Patients Imports
import '../features/patients/data/datasources/patient_remote_datasource.dart';
import '../features/patients/data/repositories/patient_repository_impl.dart';
import '../features/patients/domain/repositories/patient_repository.dart';
import '../features/patients/domain/usecases/get_all_patients.dart';
import '../features/patients/domain/usecases/get_patients_by_professional.dart';

//Observations Imports
import '../features/observations/data/datasources/observations_local_datasource.dart';
import '../features/observations/data/repositories/observations_repository_impl.dart';
import '../features/observations/domain/repositories/observations_repository.dart';
import '../features/observations/domain/usecases/add_observation.dart';
import '../features/observations/domain/usecases/get_observations_by_patient.dart';
import '../features/observations/presentation/bloc/observations_bloc.dart';


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
  _initSpecialist();
  _initPatients();
  _initObservations();
}

void _initAuth() {
  // Blocs
  getIt.registerFactory(() => AuthBloc(
        loginUser: getIt(),
        registerUser: getIt(),
        registerSpecialist: getIt(),
        forgotPassword: getIt(),
        sessionCubit: getIt(),
      ));

  // Use cases
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => RegisterUser(getIt()));
  getIt.registerLazySingleton(() => RegisterSpecialist(getIt()));
  getIt.registerLazySingleton(() => ForgotPassword(getIt()));

  // Repositories and DataSources
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: getIt()));
}

void _initDiary() {
  // Blocs - Updated to include saveEmotion dependency
  getIt.registerFactory(() => DiaryBloc(
    getEmotions: getIt(), 
    saveEmotion: getIt(),  // Changed from saveDiaryEntry to saveEmotion
    getNotes: getIt(),
    sessionCubit: getIt()
  ));
  
  // Use cases
  getIt.registerLazySingleton(() => GetEmotions(getIt()));
  getIt.registerLazySingleton(() => SaveEmotion(getIt()));  // New use case
  
  getIt.registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<DiaryRemoteDataSource>(() => DiaryRemoteDataSourceImpl(apiClient: getIt()));
}

void _initNotes() {
  // Blocs
  getIt.registerFactory(() => NotesBloc(
    getNotes: getIt(), 
    addNote: getIt(), 
    updateNote: getIt(),
    sessionCubit: getIt()
  ));

  // Use cases
  getIt.registerLazySingleton(() => GetNotes(getIt()));
  getIt.registerLazySingleton(() => AddNote(getIt()));
  getIt.registerLazySingleton(() => UpdateNote(getIt()));
  
  // Repositories and DataSources
  getIt.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<NotesRemoteDataSource>(() => NotesRemoteDataSourceImpl(apiClient: getIt()));
}

void _initTasks() {
  // Blocs
  getIt.registerFactory(() => TasksBloc(getTasks: getIt(), addTask: getIt(), toggleTaskCompletion: getIt()));
  
  // Use cases
  getIt.registerLazySingleton(() => GetTasks(getIt()));
  getIt.registerLazySingleton(() => tasks_add.AddTask(getIt()));
  getIt.registerLazySingleton(() => ToggleTaskCompletion(getIt()));
  
  // Repositories and DataSources
  getIt.registerLazySingleton<TasksRepository>(() => TasksRepositoryImpl(localDataSource: getIt()));
  getIt.registerLazySingleton<TasksLocalDataSource>(() => TasksLocalDataSourceImpl());
}

void _initStatistics() {
  // Blocs
  getIt.registerFactory(() => StatisticsBloc(getStatisticsData: getIt(), sessionCubit: getIt()));
  
  // Use cases
  getIt.registerLazySingleton(() => GetStatisticsData(getIt()));
  
  // Repositories and DataSources
  getIt.registerLazySingleton<StatisticsRepository>(() => StatisticsRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<StatisticsRemoteDataSource>(() => StatisticsRemoteDataSourceImpl(apiClient: getIt()));
}

void _initSpecialist() {
  // Blocs
  getIt.registerFactory(() => SpecialistDashboardBloc(
    getAppointments: getIt(), 
    getAllPatients: getIt(), // Nueva dependencia para obtener todos los pacientes
    getPatients: getIt(),    // Dependencia existente para pacientes por profesional
    sessionCubit: getIt()
  ));
  
  // Use cases
  getIt.registerLazySingleton(() => GetAppointmentsByProfessional(getIt()));
  
  // Repositories and DataSources
  getIt.registerLazySingleton<AppointmentRepository>(() => AppointmentRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<AppointmentRemoteDataSource>(() => AppointmentRemoteDataSourceImpl(apiClient: getIt()));
}

void _initPatients() {
  // Use cases
  getIt.registerLazySingleton(() => GetAllPatients(getIt()));           // Nuevo use case
  getIt.registerLazySingleton(() => GetPatientsByProfessional(getIt())); // Use case existente
  
  // Repositories and DataSources
  getIt.registerLazySingleton<PatientRepository>(() => PatientRepositoryImpl(remoteDataSource: getIt()));
  getIt.registerLazySingleton<PatientRemoteDataSource>(() => PatientRemoteDataSourceImpl(apiClient: getIt()));
}

void _initObservations() {
  // Blocs
  getIt.registerFactory(() => ObservationsBloc(
    getObservationsByPatient: getIt(),
    addObservation: getIt(),
    sessionCubit: getIt(),
  ));
  
  // Use cases
  getIt.registerLazySingleton(() => GetObservationsByPatient(getIt()));
  getIt.registerLazySingleton(() => AddObservation(getIt()));
  
  // Repositories and DataSources
  getIt.registerLazySingleton<ObservationsRepository>(() => ObservationsRepositoryImpl(localDataSource: getIt()));
  getIt.registerLazySingleton<ObservationsLocalDataSource>(() => ObservationsLocalDataSourceImpl());
}