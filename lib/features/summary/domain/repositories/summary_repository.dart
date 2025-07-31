import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/summary_entity.dart';

abstract class SummaryRepository {
  Future<Either<Failure, SummaryEntity>> getSummaryByPatient(String patientId);
}