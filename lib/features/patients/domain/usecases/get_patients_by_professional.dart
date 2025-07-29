import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class GetPatientsByProfessional implements UseCase<List<PatientEntity>, GetPatientsParams> {
  final PatientRepository repository;

  GetPatientsByProfessional(this.repository);

  @override
  Future<Either<Failure, List<PatientEntity>>> call(GetPatientsParams params) async {
    return await repository.getPatientsByProfessional(params.professionalId);
  }
}

class GetPatientsParams extends Equatable {
  final String professionalId;

  const GetPatientsParams({required this.professionalId});

  @override
  List<Object?> get props => [professionalId];
}