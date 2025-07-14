import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (sessionState is! AuthenticatedSessionState) return;

    emit(state.copyWith(status: SpecialistStatus.loading));
    
    final appointmentsResult = await getAppointments(
      GetAppointmentsParams(professionalId: sessionState.user.id, date: DateTime.now()),
    );
    
    appointmentsResult.fold(
      (failure) => emit(state.copyWith(status: SpecialistStatus.error, errorMessage: failure.message)),
      (appointments) => emit(state.copyWith(
        status: SpecialistStatus.loaded,
        appointments: appointments,
      )),
    );
  }
}