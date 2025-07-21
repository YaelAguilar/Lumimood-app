import 'dart:developer';
import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/emotion_model.dart';

abstract class DiaryRemoteDataSource {
  Future<List<EmotionModel>> getAvailableEmotions();
  Future<void> saveNote({required String patientId, required String title, required String content});
  Future<void> saveEmotion({required String patientId, required String emotionId, required int intensity});
}

class DiaryRemoteDataSourceImpl implements DiaryRemoteDataSource {
  final ApiClient apiClient;
  DiaryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EmotionModel>> getAvailableEmotions() async {
    log('DATA SOURCE: Fetching emotions from static list.');
    await Future.delayed(const Duration(milliseconds: 100));
    return Future.value(AppEmotions.emotions);
  }

  @override
  Future<void> saveNote({required String patientId, required String title, required String content}) async {
    final response = await apiClient.post(
      '${ApiConfig.diaryBaseUrl}/record/note',
      {'idPatient': patientId, 'title': title, 'content': content},
    );
    if (response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      throw ServerException(errorBody['message'] ?? 'Failed to save note');
    }
  }

  @override
  Future<void> saveEmotion({required String patientId, required String emotionId, required int intensity}) async {
    final response = await apiClient.post(
      '${ApiConfig.diaryBaseUrl}/record/emotion',
      {'idPatient': patientId, 'emotionName': emotionId, 'intensity': intensity},
    );
    if (response.statusCode != 201) {
      final errorBody = json.decode(response.body);
      throw ServerException(errorBody['message'] ?? 'Failed to save emotion');
    }
  }
}