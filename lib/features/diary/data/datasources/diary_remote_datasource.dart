import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/diary_entry_model.dart';
import '../models/emotion_model.dart';

abstract class DiaryRemoteDataSource {
  Future<List<EmotionModel>> getAvailableEmotions();
  Future<void> saveDiaryEntry(DiaryEntryModel entry);
}

class DiaryRemoteDataSourceImpl implements DiaryRemoteDataSource {
  final ApiClient apiClient;
  DiaryRemoteDataSourceImpl({required this.apiClient});

  // Las emociones se mantienen locales por ahora, ya que la API no las provee.
  @override
  Future<List<EmotionModel>> getAvailableEmotions() async {
    log('DATA SOURCE: Fetching emotions from static list.');
    await Future.delayed(const Duration(milliseconds: 100));
    return Future.value(AppEmotions.emotions);
  }

  // Se conecta a los endpoints de la API para guardar nota y emoción
  @override
  Future<void> saveDiaryEntry(DiaryEntryModel entry) async {
    try {
      // Guardar la nota
      final noteResponse = await apiClient.post(
        '${ApiConfig.diaryBaseUrl}/record/note',
        {
          'idPatient': entry.idPatient,
          'title': entry.title,
          'content': entry.content,
        },
      );

      if (noteResponse.statusCode != 201) {
        throw ServerException('Failed to save note');
      }

      // Guardar la emoción si existe
      if (entry.emotion != null) {
        final emotionResponse = await apiClient.post(
          '${ApiConfig.diaryBaseUrl}/record/emotion',
          {
            'idPatient': entry.idPatient,
            'emotionName': entry.emotion!.name.toLowerCase(),
            'intensity': entry.intensity,
          },
        );
        if (emotionResponse.statusCode != 201) {
          throw ServerException('Failed to save emotion');
        }
      }
    } catch (e) {
      log('Error saving diary entry: $e');
      throw ServerException('Error al guardar la entrada del diario.');
    }
  }
}