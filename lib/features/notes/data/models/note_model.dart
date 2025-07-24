import 'dart:developer';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.patientId,
    required super.title,
    required super.content,
    required super.date,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    try {
      log('📝 NOTE MODEL: Parsing JSON: $json');
      
      // Extraer el ID - el microservicio probablemente devuelve un UUID
      String id;
      if (json.containsKey('idRecNote')) {
        id = json['idRecNote'].toString();
      } else if (json.containsKey('id')) {
        id = json['id'].toString();
      } else if (json.containsKey('_id')) {
        id = json['_id'].toString();
      } else {
        id = DateTime.now().millisecondsSinceEpoch.toString();
        log('⚠️ NOTE MODEL: No ID found, generated: $id');
      }

      // Extraer el patientId
      String patientId;
      if (json.containsKey('idPatient')) {
        patientId = json['idPatient'].toString();
      } else if (json.containsKey('patientId')) {
        patientId = json['patientId'].toString();
      } else if (json.containsKey('patient_id')) {
        patientId = json['patient_id'].toString();
      } else {
        throw Exception('No se encontró el ID del paciente en la respuesta');
      }

      // Extraer title
      String title = json['title']?.toString() ?? 'Sin título';
      
      // Extraer content
      String content = json['content']?.toString() ?? '';

      // Extraer fecha - puede venir en diferentes formatos
      DateTime date;
      if (json.containsKey('createdAt')) {
        try {
          date = DateTime.parse(json['createdAt'].toString());
        } catch (e) {
          log('⚠️ NOTE MODEL: Error parsing createdAt: $e');
          date = DateTime.now();
        }
      } else if (json.containsKey('created_at')) {
        try {
          date = DateTime.parse(json['created_at'].toString());
        } catch (e) {
          log('⚠️ NOTE MODEL: Error parsing created_at: $e');
          date = DateTime.now();
        }
      } else if (json.containsKey('date')) {
        try {
          date = DateTime.parse(json['date'].toString());
        } catch (e) {
          log('⚠️ NOTE MODEL: Error parsing date: $e');
          date = DateTime.now();
        }
      } else {
        date = DateTime.now();
        log('⚠️ NOTE MODEL: No date found, using current time');
      }

      final noteModel = NoteModel(
        id: id,
        patientId: patientId,
        title: title,
        content: content,
        date: date,
      );

      log('✅ NOTE MODEL: Successfully parsed note - ID: $id, Title: "$title"');
      return noteModel;

    } catch (e, stackTrace) {
      log('❌ NOTE MODEL: Error parsing JSON: $e');
      log('❌ NOTE MODEL: Stack trace: $stackTrace');
      log('❌ NOTE MODEL: JSON was: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idPatient': patientId,
      'title': title,
      'content': content,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'content': content,
    };
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, patientId: $patientId, title: "$title", content: "${content.length} chars", date: $date)';
  }
}