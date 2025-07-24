import 'dart:convert';
import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes(String patientId);
  Future<List<NoteModel>> getNotesByDate(String patientId, String date);
  Future<NoteModel> getNote(String noteId);
  Future<NoteModel> addNote(NoteModel note);
  Future<NoteModel> updateNote(String noteId, String content);
  Future<void> deleteNote(String noteId);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final ApiClient apiClient;

  NotesRemoteDataSourceImpl({required this.apiClient});

@override
Future<List<NoteModel>> getNotes(String patientId) async {
  final url = '${ApiConfig.diaryBaseUrl}/note/patient/$patientId';
  log('🌐 NOTES API: Making GET request to: $url');
  
  try {
    final response = await apiClient.get(url);
    log('🌐 NOTES API: Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      // Buscar las notas en diferentes posibles claves
      List<dynamic>? notesData;
      if (responseData is List) {
        notesData = responseData;
      } else if (responseData is Map<String, dynamic>) {
        notesData = responseData['records'] ?? 
                   responseData['data'] ?? 
                   responseData['notes'] ?? 
                   responseData['recordNotes'];
      }
      
      if (notesData == null) {
        log('⚠️ NOTES API: No notes found in response');
        return [];
      }

      log('🌐 NOTES API: Found ${notesData.length} notes');
      
      final notes = notesData.map((json) => 
        NoteModel.fromJson(json as Map<String, dynamic>)
      ).toList();
      
      return notes;
      
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw ServerException('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    if (e is ServerException) rethrow;
    throw ServerException('Error de conexión: ${e.toString()}');
  }
}

  @override
  Future<List<NoteModel>> getNotesByDate(String patientId, String date) async {
    final url = '${ApiConfig.diaryBaseUrl}/note/$patientId/$date';
    log('🌐 NOTES API: Making GET request to: $url');
    
    try {
      final response = await apiClient.get(url);
      log('🌐 NOTES API: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> notesData;
        
        if (responseData is List) {
          notesData = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          notesData = responseData['data'] as List<dynamic>;
        } else {
          return [];
        }
        
        return notesData.map((json) => 
          NoteModel.fromJson(json as Map<String, dynamic>)
        ).toList();
        
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ServerException('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<NoteModel> getNote(String noteId) async {
    final url = '${ApiConfig.diaryBaseUrl}/note/$noteId';
    log('🌐 NOTES API: Making GET request to: $url');
    
    try {
      final response = await apiClient.get(url);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return NoteModel.fromJson(responseData);
      } else {
        throw ServerException('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }

@override
Future<NoteModel> addNote(NoteModel note) async {
  final url = '${ApiConfig.diaryBaseUrl}/note';
  final body = {
    'idPatient': note.patientId,
    'title': note.title,
    'content': note.content,
  };
  
  log('🌐 NOTES API: Making POST request to: $url');
  log('🌐 NOTES API: Request body: $body');

  try {
    final response = await apiClient.post(url, body);
    log('🌐 NOTES API: Add note response status: ${response.statusCode}');
    log('🌐 NOTES API: Add note response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      log('✅ NOTES API: Note added successfully');
      
      // La respuesta viene envuelta en un objeto con 'recordNote'
      if (responseData is Map<String, dynamic> && responseData.containsKey('recordNote')) {
        return NoteModel.fromJson(responseData['recordNote'] as Map<String, dynamic>);
      } else {
        // Si por alguna razón la estructura es diferente, intentar parsear directamente
        return NoteModel.fromJson(responseData);
      }
    } else {
      final errorMessage = 'Error ${response.statusCode}: ${response.body}';
      log('❌ NOTES API: Failed to add note - $errorMessage');
      throw ServerException(errorMessage);
    }
  } catch (e) {
    if (e is ServerException) rethrow;
    log('💥 NOTES API: Unexpected error adding note: $e');
    throw ServerException('Error de conexión: ${e.toString()}');
  }
}

@override
Future<NoteModel> updateNote(String noteId, String content) async {
  final url = '${ApiConfig.diaryBaseUrl}/note/$noteId';
  final body = {'content': content};
  
  log('🌐 NOTES API: Making PUT request to: $url');
  log('🌐 NOTES API: Request body: $body');

  try {
    final response = await apiClient.put(url, body);
    log('🌐 NOTES API: Update note response status: ${response.statusCode}');
    log('🌐 NOTES API: Update note response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      log('✅ NOTES API: Note updated successfully');
      
      // Verificar si la respuesta viene envuelta
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('recordNote')) {
          return NoteModel.fromJson(responseData['recordNote'] as Map<String, dynamic>);
        } else if (responseData.containsKey('record')) {
          return NoteModel.fromJson(responseData['record'] as Map<String, dynamic>);
        } else if (responseData.containsKey('data')) {
          return NoteModel.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          // Si no encontramos la estructura esperada, crear un modelo con los datos actualizados
          log('⚠️ NOTES API: Unexpected update response structure, creating model from original data');
          // Aquí podrías devolver el modelo original con el contenido actualizado
          throw ServerException('Estructura de respuesta inesperada en actualización');
        }
      } else {
        return NoteModel.fromJson(responseData);
      }
    } else {
      throw ServerException('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    if (e is ServerException) rethrow;
    throw ServerException('Error de conexión: ${e.toString()}');
  }
}

  @override
  Future<void> deleteNote(String noteId) async {
    final url = '${ApiConfig.diaryBaseUrl}/note/$noteId';
    log('🌐 NOTES API: Making DELETE request to: $url');

    try {
      final response = await apiClient.delete(url);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Error ${response.statusCode}: ${response.body}');
      }
      
      log('✅ NOTES API: Note deleted successfully');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }
}