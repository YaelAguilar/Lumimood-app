import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tasks_repository.dart';

class AddTask implements UseCase<void, AddTaskParams> {
  final TasksRepository repository;

  AddTask(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTaskParams params) async {
    return await repository.addTask(params.title);
  }
}

class AddTaskParams extends Equatable {
  final String title;

  const AddTaskParams({required this.title});

  @override
  List<Object?> get props => [title];
}