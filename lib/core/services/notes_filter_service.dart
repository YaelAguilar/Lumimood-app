import 'dart:developer';
import '../../features/notes/domain/entities/note.dart';
import '../../features/patients/domain/entities/patient_entity.dart';

/// Servicio para filtrar notas específicas de un paciente
class NotesFilterService {
  
  /// Filtra las notas que pertenecen a un paciente específico
  static List<Note> filterNotesByPatient(List<Note> allNotes, PatientEntity patient) {
    log('🔍 NOTES FILTER: Filtering notes for patient ${patient.id} (${patient.fullName})');
    log('🔍 NOTES FILTER: Total notes to filter: ${allNotes.length}');
    
    final filteredNotes = allNotes.where((note) {
      final belongsToPatient = note.patientId == patient.id;
      if (belongsToPatient) {
        log('✅ NOTES FILTER: Note "${note.title}" belongs to patient ${patient.fullName}');
      }
      return belongsToPatient;
    }).toList();
    
    // Ordenar por fecha, más recientes primero
    filteredNotes.sort((a, b) => b.date.compareTo(a.date));
    
    log('📊 NOTES FILTER: Found ${filteredNotes.length} notes for patient ${patient.fullName}');
    
    return filteredNotes;
  }
  
  /// Obtiene estadísticas de las notas de un paciente
  static Map<String, dynamic> getPatientNotesStats(List<Note> patientNotes) {
    if (patientNotes.isEmpty) {
      return {
        'totalNotes': 0,
        'notesThisMonth': 0,
        'averageLength': 0,
        'lastNoteDate': null,
      };
    }
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    
    final notesThisMonth = patientNotes.where((note) {
      return note.date.isAfter(thisMonth);
    }).length;
    
    final averageLength = patientNotes.isNotEmpty 
      ? patientNotes.map((note) => note.content.length).reduce((a, b) => a + b) / patientNotes.length
      : 0;
    
    return {
      'totalNotes': patientNotes.length,
      'notesThisMonth': notesThisMonth,
      'averageLength': averageLength.round(),
      'lastNoteDate': patientNotes.isNotEmpty ? patientNotes.first.date : null,
    };
  }
}