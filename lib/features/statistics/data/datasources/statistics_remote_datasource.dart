import 'dart:developer';
import '../models/statistics_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<StatisticsModel> getStatisticsData();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  @override
  Future<StatisticsModel> getStatisticsData() async {
    log('DATA SOURCE: Fetching statistics data from remote source.');
    await Future.delayed(const Duration(milliseconds: 800));

    final mockData = {
      "labels": ['Feliz', 'Sorpresa', 'Enojo', 'Miedo', 'Tristeza', 'Disgusto'],
      "values": [8.5, 5.0, 3.2, 2.0, 6.8, 4.0],
    };

    return StatisticsModel.fromJson(mockData);
  }
}