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
    final response = await apiClient.get('${ApiConfig.diaryBaseUrl}/record/note/patient/$patientId');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['recordNote'];
      return data.map((json) => NoteModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to load notes');
    }
  }

  @override
  Future<void> addNote(NoteModel note) async {
    final response = await apiClient.post(
      '${ApiConfig.diaryBaseUrl}/record/note',
      note.toJson(),
    );

    if (response.statusCode != 201) {
      log('Failed to add note: ${response.body}');
      throw ServerException('Failed to add note');
    }
  }
}