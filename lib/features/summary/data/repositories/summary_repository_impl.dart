import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/summary_entity.dart';
import '../../domain/repositories/summary_repository.dart';
import '../datasources/summary_local_datasource.dart';

class SummaryRepositoryImpl implements SummaryRepository {
  final SummaryLocalDataSource localDataSource;

  SummaryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, SummaryEntity>> getSummaryByPatient(String patientId) async {
    try {
      final summary = await localDataSource.getSummaryByPatient(patientId);
      return Right(summary);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}