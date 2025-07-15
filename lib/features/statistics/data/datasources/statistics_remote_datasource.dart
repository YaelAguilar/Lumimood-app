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
    final url = '${ApiConfig.diaryBaseUrl}/loggin/emotion/$patientId/$formattedDate';
    log('📊 STATISTICS API: Fetching from: $url');
    
    try {
      final response = await apiClient.get(url);
      log('📊 STATISTICS API: Response status: ${response.statusCode}');
      log('📊 STATISTICS API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        log('📊 STATISTICS API: Parsed response: $responseData');
        
        // Verificar si la respuesta contiene datos válidos
        final Map<String, double> emotionCounts = {};
        
        if (responseData is Map<String, dynamic>) {
          // Buscar datos en diferentes claves posibles
          List<dynamic>? loggingData;
          
          if (responseData.containsKey('loggingEmotion')) {
            final rawData = responseData['loggingEmotion'];
            if (rawData is List) {
              loggingData = rawData;
            } else if (rawData == null) {
              log('📊 STATISTICS API: loggingEmotion is null, using empty data');
              loggingData = [];
            }
          } else if (responseData.containsKey('data')) {
            final rawData = responseData['data'];
            if (rawData is List) {
              loggingData = rawData;
            } else if (rawData == null) {
              loggingData = [];
            }
          }
          
          if (loggingData != null) {
            for (var item in loggingData) {
              if (item is Map<String, dynamic>) {
                final emotionName = item['emotionName']?.toString() ?? 'unknown';
                final count = (item['count'] as num?)?.toDouble() ?? 0.0;
                emotionCounts[emotionName] = count;
              }
            }
          }
        }
        
        // Si no hay datos, crear datos por defecto
        if (emotionCounts.isEmpty) {
          log('📊 STATISTICS API: No emotion data found, using default empty data');
          emotionCounts['Sin datos'] = 0.0;
        }

        final mockData = {
          "labels": emotionCounts.keys.toList(),
          "values": emotionCounts.values.toList(),
        };
        
        log('📊 STATISTICS API: Processed data: $mockData');
        return StatisticsModel.fromJson(mockData);
        
      } else if (response.statusCode == 404) {
        log('📊 STATISTICS API: No statistics found (404), returning empty data');
        return const StatisticsModel(
          labels: ['Sin datos'],
          values: [0.0],
        );
      } else {
        throw ServerException('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      log('💥 STATISTICS API: Error: $e');
      // En caso de error, retornar datos vacíos en lugar de fallar
      return const StatisticsModel(
        labels: ['Error'],
        values: [0.0],
      );
    }
  }
}