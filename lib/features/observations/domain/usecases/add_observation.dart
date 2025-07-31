import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/observation.dart';
import '../repositories/observations_repository.dart';

class AddObservation implements UseCase<void, AddObservationParams> {
  final ObservationsRepository repository;

  AddObservation(this.repository);

  @override
  Future<Either<Failure, void>> call(AddObservationParams params) async {
    final observation = Observation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: params.patientId,
      professionalId: params.professionalId,
      professionalName: params.professionalName,
      content: params.content,
      date: DateTime.now(),
      type: params.type,
      priority: params.priority,
    );
    
    return await repository.addObservation(observation);
  }
}

class AddObservationParams extends Equatable {
  final String patientId;
  final String professionalId;
  final String professionalName;
  final String content;
  final ObservationType type;
  final ObservationPriority priority;

  const AddObservationParams({
    required this.patientId,
    required this.professionalId,
    required this.professionalName,
    required this.content,
    required this.type,
    required this.priority,
  });

  @override
  List<Object?> get props => [
        patientId,
        professionalId,
        professionalName,
        content,
        type,
        priority,
      ];
}