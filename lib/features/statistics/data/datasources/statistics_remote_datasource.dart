import 'dart:convert';
import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/statistics_model.dart';
import 'package:intl/intl.dart';

abstract class StatisticsRemoteDataSource {
  Future<StatisticsModel> getStatisticsData(String patientId, DateTime date);
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final ApiClient apiClient;

  StatisticsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<StatisticsModel> getStatisticsData(String patientId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    log('DATA SOURCE: Fetching statistics data from remote source for patient $patientId on $formattedDate');
    
    final response = await apiClient.get('${ApiConfig.diaryBaseUrl}/loggin/emotion/$patientId/$formattedDate');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // La API devuelve un formato diferente, hay que adaptarlo
      // Ejemplo de respuesta API: { "loggingEmotion": [{ "emotionName": "felicidad", "count": 5 }, ...] }
      
      final Map<String, double> emotionCounts = {};
      final List loggingData = responseData['loggingEmotion'];

      for (var item in loggingData) {
        emotionCounts[item['emotionName']] = (item['count'] as int).toDouble();
      }

      final mockData = {
        "labels": emotionCounts.keys.toList(),
        "values": emotionCounts.values.toList(),
      };
      
      return StatisticsModel.fromJson(mockData);
    } else {
      throw ServerException('Failed to load statistics');
    }
  }
}