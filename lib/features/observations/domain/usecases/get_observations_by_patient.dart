import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/observation.dart';
import '../repositories/observations_repository.dart';

class GetObservationsByPatient implements UseCase<List<Observation>, GetObservationsByPatientParams> {
  final ObservationsRepository repository;

  GetObservationsByPatient(this.repository);

  @override
  Future<Either<Failure, List<Observation>>> call(GetObservationsByPatientParams params) async {
    return await repository.getObservationsByPatient(params.patientId);
  }
}

class GetObservationsByPatientParams extends Equatable {
  final String patientId;

  const GetObservationsByPatientParams({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}