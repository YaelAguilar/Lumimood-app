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
  Future<Either<Failure, Statistics>> getStatisticsData() async {
    try {
      final remoteStatistics = await remoteDataSource.getStatisticsData();
      return Right(remoteStatistics);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}