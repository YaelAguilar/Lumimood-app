import 'dart:developer';
import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/emotion_model.dart';

abstract class DiaryRemoteDataSource {
  Future<List<EmotionModel>> getAvailableEmotions();
  Future<void> saveEmotion({required String patientId, required String emotionName, required int intensity});
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
  Future<void> saveEmotion({required String patientId, required String emotionName, required int intensity}) async {
    log('📊 DIARY API: Saving emotion - Patient: $patientId, Emotion: $emotionName, Intensity: $intensity');
    
    final url = '${ApiConfig.diaryBaseUrl}/emotion';
    final body = {
      'idPatient': patientId,
      'emotionName': emotionName,
      'intensity': intensity,
    };

    log('📊 DIARY API: Making POST request to: $url');
    log('📊 DIARY API: Request body: $body');

    try {
      final response = await apiClient.post(url, body);
      log('📊 DIARY API: Response status: ${response.statusCode}');
      log('📊 DIARY API: Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('✅ DIARY API: Emotion saved successfully');
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Error al guardar la emoción';
        log('❌ DIARY API: Failed to save emotion - $errorMessage');
        throw ServerException(errorMessage);
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      log('💥 DIARY API: Unexpected error: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }
}