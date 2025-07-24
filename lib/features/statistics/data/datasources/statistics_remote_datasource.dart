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
    final url = '${ApiConfig.diaryBaseUrl}/record/emotion/$patientId/$formattedDate';
    log('📊 STATISTICS API: Fetching from: $url');
    
    try {
      final response = await apiClient.get(url);
      log('📊 STATISTICS API: Response status: ${response.statusCode}');
      log('📊 STATISTICS API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        log('📊 STATISTICS API: Parsed response: $responseData');
        
        // Process the response data
        final Map<String, double> emotionCounts = {};
        
        if (responseData is List) {
          // If response is directly a list of emotion records
          for (var record in responseData) {
            if (record is Map<String, dynamic>) {
              final emotionName = record['emotionName']?.toString() ?? 'unknown';
              final intensity = (record['intensity'] as num?)?.toDouble() ?? 0.0;
              
              // Aggregate intensities for same emotions (you could also count occurrences)
              if (emotionCounts.containsKey(emotionName)) {
                emotionCounts[emotionName] = emotionCounts[emotionName]! + intensity;
              } else {
                emotionCounts[emotionName] = intensity;
              }
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          // If response is wrapped in an object
          List<dynamic>? records;
          
          if (responseData.containsKey('records')) {
            records = responseData['records'] as List<dynamic>?;
          } else if (responseData.containsKey('data')) {
            records = responseData['data'] as List<dynamic>?;
          } else if (responseData.containsKey('emotions')) {
            records = responseData['emotions'] as List<dynamic>?;
          }
          
          if (records != null) {
            for (var record in records) {
              if (record is Map<String, dynamic>) {
                final emotionName = record['emotionName']?.toString() ?? 'unknown';
                final intensity = (record['intensity'] as num?)?.toDouble() ?? 0.0;
                
                if (emotionCounts.containsKey(emotionName)) {
                  emotionCounts[emotionName] = emotionCounts[emotionName]! + intensity;
                } else {
                  emotionCounts[emotionName] = intensity;
                }
              }
            }
          }
        }
        
        // If no data found, create default empty data
        if (emotionCounts.isEmpty) {
          log('📊 STATISTICS API: No emotion data found, using default empty data');
          emotionCounts['Sin datos'] = 0.0;
        }

        final processedData = {
          "labels": emotionCounts.keys.toList(),
          "values": emotionCounts.values.toList(),
        };
        
        log('📊 STATISTICS API: Processed data: $processedData');
        return StatisticsModel.fromJson(processedData);
        
      } else if (response.statusCode == 404) {
        log('📊 STATISTICS API: No statistics found (404), returning empty data');
        return const StatisticsModel(
          labels: ['Sin registros'],
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
      // In case of error, return empty data instead of failing
      return const StatisticsModel(
        labels: ['Error de conexión'],
        values: [0.0],
      );
    }
  }
}