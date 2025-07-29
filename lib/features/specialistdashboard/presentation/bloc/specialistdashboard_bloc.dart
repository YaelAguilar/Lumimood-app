import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/session/session_cubit.dart';
import '../../../patients/domain/entities/patient_entity.dart';
import '../../../patients/domain/usecases/get_patients_by_professional.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/get_appointments_by_professional.dart';

part 'specialistdashboard_event.dart';
part 'specialistdashboard_state.dart';

class SpecialistDashboardBloc extends Bloc<SpecialistDashboardEvent, SpecialistDashboardState> {
  final GetAppointmentsByProfessional getAppointments;
  final GetPatientsByProfessional getPatients;
  final SessionCubit sessionCubit;

  SpecialistDashboardBloc({
    required this.getAppointments,
    required this.getPatients,
    required this.sessionCubit,
  }) : super(SpecialistDashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadPatients>(_onLoadPatients);
    on<ChangeSelectedDate>(_onChangeSelectedDate);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<SpecialistDashboardState> emit) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! AuthenticatedSessionState) {
      emit(state.copyWith(
        status: DashboardStatus.error, 
        errorMessage: 'No se pudo verificar la sesión del usuario.'
      ));
      return;
    }

    emit(state.copyWith(status: DashboardStatus.loading));
    log('🏥 SPECIALIST DASHBOARD: Loading appointments for ${sessionState.user.name}...');
    
    try {
      final appointmentsResult = await getAppointments(
        GetAppointmentsParams(
          professionalId: sessionState.user.id, 
          date: state.selectedDate
        ),
      );
      
      appointmentsResult.fold(
        (failure) {
          log('❌ SPECIALIST DASHBOARD: Failed to load appointments - ${failure.message}');
          emit(state.copyWith(
            status: DashboardStatus.error, 
            errorMessage: failure.message
          ));
        },
        (appointments) {
          log('✅ SPECIALIST DASHBOARD: Successfully loaded ${appointments.length} appointments');
          emit(state.copyWith(
            status: DashboardStatus.loaded,
            appointments: appointments,
            professionalName: sessionState.user.name,
            professionalId: sessionState.user.id,
          ));
        },
      );
    } catch (e) {
      log('💥 SPECIALIST DASHBOARD: Unexpected error - $e');
      emit(state.copyWith(
        status: DashboardStatus.error, 
        errorMessage: 'Error inesperado: ${e.toString()}'
      ));
    }
  }

  Future<void> _onLoadPatients(LoadPatients event, Emitter<SpecialistDashboardState> emit) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! AuthenticatedSessionState) {
      emit(state.copyWith(
        patientsStatus: PatientsStatus.error,
        errorMessage: 'No se pudo verificar la sesión del usuario.'
      ));
      return;
    }

    emit(state.copyWith(patientsStatus: PatientsStatus.loading));
    log('👥 SPECIALIST DASHBOARD: Loading patients for professional ${sessionState.user.id}...');

    try {
      final patientsResult = await getPatients(
        GetPatientsParams(professionalId: sessionState.user.id),
      );

      patientsResult.fold(
        (failure) {
          log('❌ SPECIALIST DASHBOARD: Failed to load patients - ${failure.message}');
          emit(state.copyWith(
            patientsStatus: PatientsStatus.error,
            errorMessage: failure.message,
          ));
        },
        (patients) {
          log('✅ SPECIALIST DASHBOARD: Successfully loaded ${patients.length} patients');
          emit(state.copyWith(
            patientsStatus: PatientsStatus.loaded,
            patients: patients,
          ));
        },
      );
    } catch (e) {
      log('💥 SPECIALIST DASHBOARD: Unexpected error loading patients - $e');
      emit(state.copyWith(
        patientsStatus: PatientsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      ));
    }
  }

  void _onChangeSelectedDate(ChangeSelectedDate event, Emitter<SpecialistDashboardState> emit) {
    emit(state.copyWith(selectedDate: event.date));
    add(LoadDashboardData());
  }

  void _onRefreshDashboard(RefreshDashboard event, Emitter<SpecialistDashboardState> emit) {
    add(LoadDashboardData());
  }
}