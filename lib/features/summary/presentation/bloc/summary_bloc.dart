import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/session/session_cubit.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/entities/summary_entity.dart';
import '../../domain/usecases/get_summary.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final GetSummary getSummary;
  final SessionCubit sessionCubit;

  SummaryBloc({
    required this.getSummary,
    required this.sessionCubit,
  }) : super(const SummaryState()) {
    on<LoadSummary>(_onLoadSummary);
    on<LoadSummaryForPatient>(_onLoadSummaryForPatient);
  }

  Future<void> _onLoadSummary(LoadSummary event, Emitter<SummaryState> emit) async {
    log('📋 SUMMARY BLOC: Loading summary for current user');
    
    final sessionState = sessionCubit.state;
    if (sessionState is! AuthenticatedSessionState) {
      emit(state.copyWith(
        status: SummaryStatus.error,
        errorMessage: 'Usuario no autenticado',
      ));
      return;
    }

    // Solo los pacientes pueden ver su propio resumen desde el diary
    if (sessionState.user.typeAccount != AccountType.patient) {
      emit(state.copyWith(
        status: SummaryStatus.error,
        errorMessage: 'Solo los pacientes pueden acceder a esta función',
      ));
      return;
    }

    await _loadSummaryForPatient(sessionState.user.id, emit);
  }

  Future<void> _onLoadSummaryForPatient(LoadSummaryForPatient event, Emitter<SummaryState> emit) async {
    log('📋 SUMMARY BLOC: Loading summary for specific patient: ${event.patientId}');
    await _loadSummaryForPatient(event.patientId, emit);
  }

  Future<void> _loadSummaryForPatient(String patientId, Emitter<SummaryState> emit) async {
    emit(state.copyWith(status: SummaryStatus.loading));

    try {
      final result = await getSummary(GetSummaryParams(patientId: patientId));

      result.fold(
        (failure) {
          log('❌ SUMMARY BLOC: Failed to load summary - ${failure.message}');
          emit(state.copyWith(
            status: SummaryStatus.error,
            errorMessage: failure.message,
          ));
        },
        (summary) {
          log('✅ SUMMARY BLOC: Successfully loaded summary for patient $patientId');
          emit(state.copyWith(
            status: SummaryStatus.loaded,
            summary: summary,
          ));
        },
      );
    } catch (e) {
      log('💥 SUMMARY BLOC: Unexpected error - $e');
      emit(state.copyWith(
        status: SummaryStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      ));
    }
  }
}