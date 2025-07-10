import '../../domain/entities/statistics.dart';

class StatisticsModel extends Statistics {
  const StatisticsModel({
    required super.labels,
    required super.values,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      labels: List<String>.from(json['labels']),
      values: List<double>.from(json['values'].map((x) => x.toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labels': labels,
      'values': values,
    };
  }
}