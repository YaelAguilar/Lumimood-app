import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByProfessional(
      String professionalId, DateTime date) async {
    try {
      final appointments = await remoteDataSource.getAppointmentsByProfessional(professionalId, date);
      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}