import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/tasks_local_datasource.dart';
import '../models/task_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksLocalDataSource localDataSource;

  TasksRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final localTasks = await localDataSource.getTasks();
      return Right(localTasks);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Future<Either<Failure, void>> addTask(String title) async {
    try {
      final newTask = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      );
      await localDataSource.addTask(newTask);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleTaskCompletion(String taskId) async {
    try {
      final List<dynamic> tasks = await localDataSource.getTasks();
      final taskIndex = tasks.indexWhere((task) => task.id == taskId);

      if (taskIndex == -1) {
        return Left(CacheFailure());
      }
      
      final taskToUpdate = tasks[taskIndex];
      final updatedTask = taskToUpdate.copyWith(isCompleted: !taskToUpdate.isCompleted);
      
      await localDataSource.updateTask(updatedTask);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}