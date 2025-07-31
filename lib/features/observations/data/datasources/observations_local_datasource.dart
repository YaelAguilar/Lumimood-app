import 'dart:developer';
import '../../domain/entities/observation.dart';

/// Servicio de datos local para observaciones
abstract class ObservationsLocalDataSource {
  Future<List<Observation>> getObservationsByPatient(String patientId);
  Future<List<Observation>> getObservationsByProfessional(String professionalId);
  Future<void> addObservation(Observation observation);
  Future<void> deleteObservation(String observationId);
}

class ObservationsLocalDataSourceImpl implements ObservationsLocalDataSource {
  // Datos estáticos de prueba
  final List<Observation> _cachedObservations = [
    Observation(
      id: '1',
      patientId: 'patient_001',
      professionalId: 'professional_001',
      professionalName: 'Dr. García',
      content: 'El paciente muestra una mejora significativa en el manejo de la ansiedad. Ha implementado correctamente las técnicas de respiración enseñadas.',
      date: DateTime.now().subtract(const Duration(days: 7)),
      type: ObservationType.progress,
      priority: ObservationPriority.normal,
    ),
    Observation(
      id: '2',
      patientId: 'patient_001',
      professionalId: 'professional_001',
      professionalName: 'Dr. García',
      content: 'Se observa dificultad para mantener el sueño. Recomiendo establecer una rutina de higiene del sueño más estricta.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      type: ObservationType.concern,
      priority: ObservationPriority.high,
    ),
    Observation(
      id: '3',
      patientId: 'patient_002',
      professionalId: 'professional_001',
      professionalName: 'Dr. García',
      content: 'Excelente adherencia al tratamiento. El paciente completa todas las tareas asignadas puntualmente.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: ObservationType.progress,
      priority: ObservationPriority.normal,
    ),
  ];

  @override
  Future<List<Observation>> getObservationsByPatient(String patientId) async {
    log('📋 OBSERVATIONS DATA SOURCE: Fetching observations for patient: $patientId');
    await Future.delayed(const Duration(milliseconds: 400));
    
    final observations = _cachedObservations
        .where((obs) => obs.patientId == patientId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Más recientes primero
    
    log('📋 OBSERVATIONS DATA SOURCE: Found ${observations.length} observations');
    return observations;
  }

  @override
  Future<List<Observation>> getObservationsByProfessional(String professionalId) async {
    log('📋 OBSERVATIONS DATA SOURCE: Fetching observations by professional: $professionalId');
    await Future.delayed(const Duration(milliseconds: 400));
    
    final observations = _cachedObservations
        .where((obs) => obs.professionalId == professionalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return observations;
  }

  @override
  Future<void> addObservation(Observation observation) async {
    log('📋 OBSERVATIONS DATA SOURCE: Adding new observation');
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedObservations.add(observation);
    log('✅ OBSERVATIONS DATA SOURCE: Observation added successfully');
  }

  @override
  Future<void> deleteObservation(String observationId) async {
    log('📋 OBSERVATIONS DATA SOURCE: Deleting observation: $observationId');
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedObservations.removeWhere((obs) => obs.id == observationId);
  }
}