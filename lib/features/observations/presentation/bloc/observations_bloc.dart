import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/session/session_cubit.dart';
import '../../../authentication/domain/entities/user_entity.dart';
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
    
    try {
      emit(state.copyWith(creationStatus: ObservationCreationStatus.loading));
      
      // PASO 1: Validar entrada
      if (event.patientId.isEmpty || event.content.trim().isEmpty) {
        log('❌ OBSERVATIONS BLOC: Invalid input data');
        emit(state.copyWith(
          creationStatus: ObservationCreationStatus.error,
          errorMessage: 'Datos de entrada inválidos',
        ));
        return;
      }

      // PASO 2: Verificar sesión
      final sessionState = sessionCubit.state;
      log('📋 OBSERVATIONS BLOC: Session state type: ${sessionState.runtimeType}');
      
      if (sessionState is! AuthenticatedSessionState) {
        log('❌ OBSERVATIONS BLOC: No authenticated session found');
        emit(state.copyWith(
          creationStatus: ObservationCreationStatus.error,
          errorMessage: 'Sesión no válida. Por favor, inicia sesión nuevamente.',
        ));
        return;
      }

      // PASO 3: Verificar que el usuario sea especialista
      final user = sessionState.user;
      log('📋 OBSERVATIONS BLOC: User type: ${user.typeAccount}');
      
      if (user.typeAccount != AccountType.specialist) {
        log('❌ OBSERVATIONS BLOC: User is not a specialist');
        emit(state.copyWith(
          creationStatus: ObservationCreationStatus.error,
          errorMessage: 'Solo los especialistas pueden agregar observaciones.',
        ));
        return;
      }

      // PASO 4: Obtener información del profesional
      final professionalId = user.id;
      final professionalName = user.name;

      log('📋 OBSERVATIONS BLOC: Professional info - ID: $professionalId, Name: $professionalName');

      // PASO 5: Crear los parámetros
      final params = AddObservationParams(
        patientId: event.patientId,
        professionalId: professionalId,
        professionalName: professionalName,
        content: event.content.trim(),
        type: event.type,
        priority: event.priority,
      );

      log('📋 OBSERVATIONS BLOC: Calling addObservation use case...');

      // PASO 6: Ejecutar el caso de uso
      final result = await addObservation(params);

      // PASO 7: Manejar el resultado
      result.fold(
        (failure) {
          log('❌ OBSERVATIONS BLOC: Failed to add observation - ${failure.message}');
          emit(state.copyWith(
            creationStatus: ObservationCreationStatus.error,
            errorMessage: 'Error al guardar: ${failure.message}',
          ));
        },
        (_) {
          log('✅ OBSERVATIONS BLOC: Observation added successfully');
          emit(state.copyWith(creationStatus: ObservationCreationStatus.success));
          
          // Recargar las observaciones
          add(LoadObservations(patientId: event.patientId));
        },
      );
    } catch (e, stackTrace) {
      log('💥 OBSERVATIONS BLOC: Unexpected error adding observation');
      log('💥 Error: $e');
      log('💥 Stack trace: $stackTrace');
      
      emit(state.copyWith(
        creationStatus: ObservationCreationStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      ));
    }
    
    // Reset creation status después de un tiempo
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!isClosed) {
        emit(state.copyWith(creationStatus: ObservationCreationStatus.initial));
      }
    } catch (e) {
      // Ignorar errores en el reset
      log('⚠️ OBSERVATIONS BLOC: Error resetting status: $e');
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
      // CORRECCIÓN: Solo devolver el ID si es un paciente
      if (sessionState.user.typeAccount == AccountType.patient) {
        log('📋 OBSERVATIONS BLOC: Current patient ID: ${sessionState.user.id}');
        return sessionState.user.id;
      } else {
        log('📋 OBSERVATIONS BLOC: Current user is not a patient, returning null');
        return null;
      }
    }
    log('❌ OBSERVATIONS BLOC: No authenticated session found');
    return null;
  }
}