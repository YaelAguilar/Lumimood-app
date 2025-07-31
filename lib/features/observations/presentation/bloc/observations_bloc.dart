import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/observation.dart';
import '../../domain/usecases/add_observation.dart';
import '../../domain/usecases/get_observations_by_patient.dart';

part 'observations_event.dart';
part 'observations_state.dart';

class ObservationsBloc extends Bloc<ObservationsEvent, ObservationsState> {
  final GetObservationsByPatient getObservationsByPatient;
  final AddObservation addObservation;
  final SessionCubit sessionCubit;

  ObservationsBloc({
    required this.getObservationsByPatient,
    required this.addObservation,
    required this.sessionCubit,
  }) : super(const ObservationsState()) {
    on<LoadObservations>(_onLoadObservations);
    on<AddNewObservation>(_onAddNewObservation);
    on<FilterObservations>(_onFilterObservations);
  }

  Future<void> _onLoadObservations(LoadObservations event, Emitter<ObservationsState> emit) async {
    emit(state.copyWith(status: ObservationsStatus.loading));
    
    try {
      final patientId = event.patientId ?? _getCurrentPatientId();
      
      if (patientId == null) {
        emit(state.copyWith(
          status: ObservationsStatus.error,
          errorMessage: 'No se pudo identificar al paciente',
        ));
        return;
      }

      final result = await getObservationsByPatient(
        GetObservationsByPatientParams(patientId: patientId),
      );

      result.fold(
        (failure) {
          log('❌ OBSERVATIONS BLOC: Failed to load observations - ${failure.message}');
          emit(state.copyWith(
            status: ObservationsStatus.error,
            errorMessage: failure.message,
          ));
        },
        (observations) {
          log('✅ OBSERVATIONS BLOC: Successfully loaded ${observations.length} observations');
          emit(state.copyWith(
            status: ObservationsStatus.loaded,
            observations: observations,
            filteredObservations: observations,
          ));
        },
      );
    } catch (e) {
      log('💥 OBSERVATIONS BLOC: Unexpected error - $e');
      emit(state.copyWith(
        status: ObservationsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddNewObservation(AddNewObservation event, Emitter<ObservationsState> emit) async {
    emit(state.copyWith(creationStatus: ObservationCreationStatus.loading));
    
    try {
      final professional = _getProfessionalInfo();
      
      if (professional == null) {
        emit(state.copyWith(
          creationStatus: ObservationCreationStatus.error,
          errorMessage: 'No se pudo identificar al profesional',
        ));
        return;
      }

      final result = await addObservation(AddObservationParams(
        patientId: event.patientId,
        professionalId: professional['id']!,
        professionalName: professional['name']!,
        content: event.content,
        type: event.type,
        priority: event.priority,
      ));

      result.fold(
        (failure) {
          log('❌ OBSERVATIONS BLOC: Failed to add observation - ${failure.message}');
          emit(state.copyWith(
            creationStatus: ObservationCreationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) {
          log('✅ OBSERVATIONS BLOC: Observation added successfully');
          emit(state.copyWith(creationStatus: ObservationCreationStatus.success));
          // Recargar las observaciones
          add(LoadObservations(patientId: event.patientId));
        },
      );
    } catch (e) {
      log('💥 OBSERVATIONS BLOC: Unexpected error adding observation - $e');
      emit(state.copyWith(
        creationStatus: ObservationCreationStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      ));
    }
    
    // Reset creation status
    await Future.delayed(const Duration(milliseconds: 500));
    if (!isClosed) {
      emit(state.copyWith(creationStatus: ObservationCreationStatus.initial));
    }
  }

  void _onFilterObservations(FilterObservations event, Emitter<ObservationsState> emit) {
    final filtered = state.observations.where((observation) {
      if (event.type != null && observation.type != event.type) {
        return false;
      }
      if (event.priority != null && observation.priority != event.priority) {
        return false;
      }
      return true;
    }).toList();

    emit(state.copyWith(
      filteredObservations: filtered,
      selectedType: event.type,
      selectedPriority: event.priority,
    ));
  }

  String? _getCurrentPatientId() {
    final sessionState = sessionCubit.state;
    if (sessionState is AuthenticatedSessionState) {
      return sessionState.user.id;
    }
    return null;
  }

  Map<String, String>? _getProfessionalInfo() {
    final sessionState = sessionCubit.state;
    if (sessionState is AuthenticatedSessionState) {
      return {
        'id': sessionState.user.id,
        'name': 'Dr. ${sessionState.user.name}',
      };
    }
    return null;
  }
}