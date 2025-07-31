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
  // Datos estáticos de prueba ampliados
  final List<Observation> _cachedObservations = [
    // Observaciones para el paciente patient_001
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
    
    // Observaciones para el paciente patient_002
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
    
    // Observaciones adicionales para varios pacientes
    Observation(
      id: '4',
      patientId: 'patient_003',
      professionalId: 'professional_001',
      professionalName: 'Dr. García',
      content: 'Primera sesión completada. El paciente muestra disposición al cambio y comprende los objetivos terapéuticos.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: ObservationType.general,
      priority: ObservationPriority.normal,
    ),
    
    Observation(
      id: '5',
      patientId: 'patient_001',
      professionalId: 'professional_001',
      professionalName: 'Dr. García',
      content: 'Recomiendo incrementar la frecuencia de ejercicios de mindfulness. El paciente responde bien a estas técnicas.',
      date: DateTime.now().subtract(const Duration(hours: 6)),
      type: ObservationType.recommendation,
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
    
    log('📋 OBSERVATIONS DATA SOURCE: Found ${observations.length} observations for patient $patientId');
    
    // Log detallado de las observaciones encontradas
    for (int i = 0; i < observations.length; i++) {
      final obs = observations[i];
      log('  📝 Observation ${i + 1}: ${obs.type.displayName} - "${obs.content.substring(0, 50)}..."');
    }
    
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
    
    log('📋 OBSERVATIONS DATA SOURCE: Found ${observations.length} observations by professional $professionalId');
    return observations;
  }

  @override
  Future<void> addObservation(Observation observation) async {
    log('📋 OBSERVATIONS DATA SOURCE: Adding new observation');
    log('  📝 Patient ID: ${observation.patientId}');
    log('  📝 Professional: ${observation.professionalName}');
    log('  📝 Type: ${observation.type.displayName}');
    log('  📝 Priority: ${observation.priority.displayName}');
    log('  📝 Content: "${observation.content}"');
    
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedObservations.add(observation);
    
    log('✅ OBSERVATIONS DATA SOURCE: Observation added successfully. Total observations: ${_cachedObservations.length}');
    
    // Verificar que se agregó correctamente
    final addedObs = _cachedObservations.where((obs) => obs.patientId == observation.patientId).toList();
    log('📋 OBSERVATIONS DATA SOURCE: Patient ${observation.patientId} now has ${addedObs.length} observations');
  }

  @override
  Future<void> deleteObservation(String observationId) async {
    log('📋 OBSERVATIONS DATA SOURCE: Deleting observation: $observationId');
    await Future.delayed(const Duration(milliseconds: 200));
    final initialCount = _cachedObservations.length;
    _cachedObservations.removeWhere((obs) => obs.id == observationId);
    final finalCount = _cachedObservations.length;
    log('📋 OBSERVATIONS DATA SOURCE: Deleted observation. Count: $initialCount -> $finalCount');
  }

  /// Método de utilidad para obtener estadísticas de debug
  void printDebugInfo() {
    log('📋 OBSERVATIONS DATA SOURCE DEBUG INFO:');
    log('  Total observations: ${_cachedObservations.length}');
    
    // Agrupar por paciente
    final byPatient = <String, int>{};
    for (final obs in _cachedObservations) {
      byPatient[obs.patientId] = (byPatient[obs.patientId] ?? 0) + 1;
    }
    
    for (final entry in byPatient.entries) {
      log('  Patient ${entry.key}: ${entry.value} observations');
    }
  }
}