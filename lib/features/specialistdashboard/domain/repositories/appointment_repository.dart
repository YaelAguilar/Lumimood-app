import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByProfessional(
      String professionalId, DateTime date);
}