import 'dart:developer';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TasksLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
}

class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  final List<TaskModel> _cachedTasks = [
    const TaskModel(id: '1', title: 'Hacer ejercicio 30 minutos'),
    const TaskModel(id: '2', title: 'Meditar por 10 minutos', isCompleted: true),
    const TaskModel(id: '3', title: 'Escribir en el diario'),
    const TaskModel(id: '4', title: 'Leer un capítulo de un libro', isCompleted: true),
    const TaskModel(id: '5', title: 'Planificar el día de mañana'),
  ];

  @override
  Future<List<TaskModel>> getTasks() async {
    log('DATA SOURCE: Fetching tasks from local cache.');
    await Future.delayed(const Duration(milliseconds: 400));
    return Future.value(List.from(_cachedTasks));
  }

  @override
  Future<void> addTask(TaskModel task) async {
    log('DATA SOURCE: Adding new task with title: ${task.title}');
    if (task.title.isEmpty) {
      throw CacheException("Task title cannot be empty"); // CORREGIDO
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedTasks.add(task);
    return Future.value();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    log('DATA SOURCE: Updating task with id: ${task.id}');
    final index = _cachedTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      await Future.delayed(const Duration(milliseconds: 100));
      _cachedTasks[index] = task;
      return Future.value();
    } else {
      throw CacheException("Task with id ${task.id} not found"); // CORREGIDO
    }
  }
}