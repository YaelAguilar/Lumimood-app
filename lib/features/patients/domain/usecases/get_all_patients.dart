import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class GetAllPatients implements UseCase<List<PatientEntity>, NoParams> {
  final PatientRepository repository;

  GetAllPatients(this.repository);

  @override
  Future<Either<Failure, List<PatientEntity>>> call(NoParams params) async {
    return await repository.getAllPatients();
  }
}