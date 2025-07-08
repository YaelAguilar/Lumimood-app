part of 'statistics_bloc.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final List<double> values;
  final List<String> labels;
  final String? errorMessage;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.values = const [],
    this.labels = const [],
    this.errorMessage,
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    List<double>? values,
    List<String>? labels,
    String? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      values: values ?? this.values,
      labels: labels ?? this.labels,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, values, labels, errorMessage];
}