import 'package:equatable/equatable.dart';

class Statistics extends Equatable {
  final List<String> labels;
  final List<double> values;

  const Statistics({
    required this.labels,
    required this.values,
  });

  @override
  List<Object?> get props => [labels, values];
}