import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Statistics>> getStatisticsData(String patientId, DateTime date) async {
    try {
      final remoteStatistics = await remoteDataSource.getStatisticsData(patientId, date);
      return Right(remoteStatistics);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message));
    }
  }
}