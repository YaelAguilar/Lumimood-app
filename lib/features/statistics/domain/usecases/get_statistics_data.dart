import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';

class GetStatisticsData implements UseCase<Statistics, NoParams> {
  final StatisticsRepository repository;

  GetStatisticsData(this.repository);

  @override
  Future<Either<Failure, Statistics>> call(NoParams params) async {
    return await repository.getStatisticsData();
  }
}