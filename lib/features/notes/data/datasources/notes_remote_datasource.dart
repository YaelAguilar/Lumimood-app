import 'dart:convert';
import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Future<List<NoteModel>> getNotes(String patientId);
  Future<void> addNote(NoteModel note);
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final ApiClient apiClient;

  NotesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NoteModel>> getNotes(String patientId) async {
    final url = '${ApiConfig.diaryBaseUrl}/record/note/patient/$patientId';
    log('🌐 NOTES API: Making GET request to: $url');
    
    try {
      final response = await apiClient.get(url);
      log('🌐 NOTES API: Response status: ${response.statusCode}');
      log('🌐 NOTES API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        log('🌐 NOTES API: Parsed response: $responseData');
        
        // Verificar diferentes estructuras de respuesta
        List<dynamic> notesData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('recordNote')) {
            notesData = responseData['recordNote'] as List<dynamic>;
          } else if (responseData.containsKey('notes')) {
            notesData = responseData['notes'] as List<dynamic>;
          } else if (responseData.containsKey('data')) {
            notesData = responseData['data'] as List<dynamic>;
          } else {
            // Si la respuesta es un map pero sin las claves esperadas, 
            // podría ser que sea directamente la lista
            log('⚠️ NOTES API: Unexpected response structure, trying to use as list...');
            notesData = [];
          }
        } else if (responseData is List) {
          // La respuesta es directamente una lista
          notesData = responseData;
        } else {
          log('❌ NOTES API: Unexpected response type: ${responseData.runtimeType}');
          throw ServerException('Formato de respuesta inesperado');
        }

        log('🌐 NOTES API: Found ${notesData.length} notes in response');
        
        final notes = notesData.map((json) {
          log('🌐 NOTES API: Converting note: $json');
          return NoteModel.fromJson(json as Map<String, dynamic>);
        }).toList();
        
        log('✅ NOTES API: Successfully converted ${notes.length} notes');
        return notes;
        
      } else if (response.statusCode == 404) {
        log('📝 NOTES API: No notes found for patient (404) - returning empty list');
        return []; // No hay notas, retornar lista vacía
      } else {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        log('❌ NOTES API: $errorMessage');
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      log('💥 NOTES API: Unexpected error: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final url = '${ApiConfig.diaryBaseUrl}/record/note';
    final body = note.toJson();
    
    log('🌐 NOTES API: Making POST request to: $url');
    log('🌐 NOTES API: Request body: $body');

    try {
      final response = await apiClient.post(url, body);
      log('🌐 NOTES API: Add note response status: ${response.statusCode}');
      log('🌐 NOTES API: Add note response body: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorMessage = 'Error ${response.statusCode}: ${response.body}';
        log('❌ NOTES API: Failed to add note - $errorMessage');
        throw ServerException(errorMessage);
      }
      
      log('✅ NOTES API: Note added successfully');
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      log('💥 NOTES API: Unexpected error adding note: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }
}