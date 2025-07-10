import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tasks_repository.dart';

class ToggleTaskCompletion implements UseCase<void, ToggleTaskParams> {
  final TasksRepository repository;

  ToggleTaskCompletion(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleTaskParams params) async {
    return await repository.toggleTaskCompletion(params.taskId);
  }
}

class ToggleTaskParams extends Equatable {
  final String taskId;

  const ToggleTaskParams({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}