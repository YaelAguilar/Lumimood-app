import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';

class GetStatisticsData implements UseCase<Statistics, GetStatisticsParams> {
  final StatisticsRepository repository;

  GetStatisticsData(this.repository);

  @override
  Future<Either<Failure, Statistics>> call(GetStatisticsParams params) async {
    return await repository.getStatisticsData(params.patientId, params.date);
  }
}

class GetStatisticsParams extends Equatable {
  final String patientId;
  final DateTime date;

  const GetStatisticsParams({required this.patientId, required this.date});

  @override
  List<Object?> get props => [patientId, date];
}