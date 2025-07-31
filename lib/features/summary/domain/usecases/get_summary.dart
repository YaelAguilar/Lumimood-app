import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/summary_entity.dart';
import '../repositories/summary_repository.dart';

class GetSummary implements UseCase<SummaryEntity, GetSummaryParams> {
  final SummaryRepository repository;

  GetSummary(this.repository);

  @override
  Future<Either<Failure, SummaryEntity>> call(GetSummaryParams params) async {
    return await repository.getSummaryByPatient(params.patientId);
  }
}

class GetSummaryParams extends Equatable {
  final String patientId;

  const GetSummaryParams({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}