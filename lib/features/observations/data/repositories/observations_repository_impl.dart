import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/observation.dart';
import '../../domain/repositories/observations_repository.dart';
import '../datasources/observations_local_datasource.dart';

class ObservationsRepositoryImpl implements ObservationsRepository {
  final ObservationsLocalDataSource localDataSource;

  ObservationsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Observation>>> getObservationsByPatient(String patientId) async {
    try {
      final observations = await localDataSource.getObservationsByPatient(patientId);
      return Right(observations);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Observation>>> getObservationsByProfessional(String professionalId) async {
    try {
      final observations = await localDataSource.getObservationsByProfessional(professionalId);
      return Right(observations);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addObservation(Observation observation) async {
    try {
      await localDataSource.addObservation(observation);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteObservation(String observationId) async {
    try {
      await localDataSource.deleteObservation(observationId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}