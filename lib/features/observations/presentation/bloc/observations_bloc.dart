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

      log('📋 OBSERVATIONS BLOC: Loading observations for patient: $patientId');

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
    log('📋 OBSERVATIONS BLOC: Adding new observation for patient ${event.patientId}');
    emit(state.copyWith(creationStatus: ObservationCreationStatus.loading));
    
    try {
      final professional = _getProfessionalInfo();
      
      if (professional == null) {
        log('❌ OBSERVATIONS BLOC: No professional info found');
        emit(state.copyWith(
          creationStatus: ObservationCreationStatus.error,
          errorMessage: 'No se pudo identificar al profesional',
        ));
        return;
      }

      log('📋 OBSERVATIONS BLOC: Professional info - ID: ${professional['id']}, Name: ${professional['name']}');

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
          
          // Recargar las observaciones después de agregar una nueva
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
    
    // Reset creation status después de un tiempo
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!isClosed) {
      emit(state.copyWith(creationStatus: ObservationCreationStatus.initial));
    }
  }

  void _onFilterObservations(FilterObservations event, Emitter<ObservationsState> emit) {
    log('📋 OBSERVATIONS BLOC: Filtering observations - Type: ${event.type}, Priority: ${event.priority}');
    
    // Si no hay filtros, mostrar todas las observaciones
    if (event.type == null && event.priority == null) {
      emit(state.copyWith(
        filteredObservations: state.observations,
        selectedType: null,
        selectedPriority: null,
      ));
      return;
    }

    final filtered = state.observations.where((observation) {
      bool matchesType = event.type == null || observation.type == event.type;
      bool matchesPriority = event.priority == null || observation.priority == event.priority;
      
      return matchesType && matchesPriority;
    }).toList();

    log('📋 OBSERVATIONS BLOC: Filtered ${filtered.length} observations from ${state.observations.length} total');

    emit(state.copyWith(
      filteredObservations: filtered,
      selectedType: event.type,
      selectedPriority: event.priority,
    ));
  }

  String? _getCurrentPatientId() {
    final sessionState = sessionCubit.state;
    if (sessionState is AuthenticatedSessionState) {
      log('📋 OBSERVATIONS BLOC: Current patient ID: ${sessionState.user.id}');
      return sessionState.user.id;
    }
    log('❌ OBSERVATIONS BLOC: No authenticated session found');
    return null;
  }

  Map<String, String>? _getProfessionalInfo() {
    final sessionState = sessionCubit.state;
    if (sessionState is AuthenticatedSessionState) {
      final professionalInfo = {
        'id': sessionState.user.id,
        'name': sessionState.user.name,
      };
      return professionalInfo;
    }
    log('❌ OBSERVATIONS BLOC: No professional session found');
    return null;
  }
}