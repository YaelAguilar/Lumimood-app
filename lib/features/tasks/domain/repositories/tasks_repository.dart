import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class TasksRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, void>> addTask(String title);
  Future<Either<Failure, void>> toggleTaskCompletion(String taskId);
}