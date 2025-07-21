import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/get_appointments_by_professional.dart';

part 'specialist_event.dart';
part 'specialist_state.dart';

class SpecialistBloc extends Bloc<SpecialistEvent, SpecialistState> {
  final GetAppointmentsByProfessional getAppointments;
  final SessionCubit sessionCubit;

  SpecialistBloc({
    required this.getAppointments,
    required this.sessionCubit,
  }) : super(const SpecialistState()) {
    on<LoadSpecialistDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(LoadSpecialistDashboard event, Emitter<SpecialistState> emit) async {
    final sessionState = sessionCubit.state;
    if (sessionState is! AuthenticatedSessionState) {
      emit(state.copyWith(status: SpecialistStatus.error, errorMessage: 'No se pudo verificar la sesión del usuario.'));
      return;
    }

    emit(state.copyWith(status: SpecialistStatus.loading));
    log('SpecialistBloc: Emitted loading state. Fetching appointments...');
    
    try {
      final appointmentsResult = await getAppointments(
        GetAppointmentsParams(professionalId: sessionState.user.id, date: DateTime.now()),
      );
      
      appointmentsResult.fold(
        (failure) {
          log('SpecialistBloc: Fetched appointments resulted in a failure: ${failure.message}');
          emit(state.copyWith(status: SpecialistStatus.error, errorMessage: failure.message));
        },
        (appointments) {
          log('SpecialistBloc: Successfully fetched/mocked ${appointments.length} appointments. Emitting loaded state.');
          emit(state.copyWith(
            status: SpecialistStatus.loaded,
            appointments: appointments,
          ));
        },
      );
    } catch (e) {
      log('SpecialistBloc: CRITICAL UNCAUGHT ERROR: ${e.toString()}');
      emit(state.copyWith(status: SpecialistStatus.error, errorMessage: 'Error crítico en la aplicación: ${e.toString()}'));
    }
  }
}