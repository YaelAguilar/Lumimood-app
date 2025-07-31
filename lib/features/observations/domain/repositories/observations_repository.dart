import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/observation.dart';

abstract class ObservationsRepository {
  Future<Either<Failure, List<Observation>>> getObservationsByPatient(String patientId);
  Future<Either<Failure, List<Observation>>> getObservationsByProfessional(String professionalId);
  Future<Either<Failure, void>> addObservation(Observation observation);
  Future<Either<Failure, void>> deleteObservation(String observationId);
}