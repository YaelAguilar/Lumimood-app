import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PatientEntity>>> getAllPatients() async {
    try {
      final remotePatients = await remoteDataSource.getAllPatients();
      return Right(remotePatients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PatientEntity>>> getPatientsByProfessional(String professionalId) async {
    try {
      final remotePatients = await remoteDataSource.getPatientsByProfessional(professionalId);
      return Right(remotePatients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}