import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, Statistics>> getStatisticsData();
}