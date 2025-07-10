import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final ToggleTaskCompletion toggleTaskCompletion;

  TasksBloc({
    required this.getTasks,
    required this.addTask,
    required this.toggleTaskCompletion,
  }) : super(const TasksState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddNewTask>(_onAddNewTask);
    on<ToggleTask>(_onToggleTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    emit(state.copyWith(status: TasksStatus.loading));
    final result = await getTasks(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(status: TasksStatus.error, errorMessage: 'No se pudieron cargar las tareas.')),
      (tasks) => emit(state.copyWith(status: TasksStatus.loaded, tasks: tasks)),
    );
  }

  Future<void> _onAddNewTask(AddNewTask event, Emitter<TasksState> emit) async {
    final result = await addTask(AddTaskParams(title: event.title));

    result.fold(
      (failure) {
        log('Failed to add task: $failure');
      },
      (_) {
        add(LoadTasks());
      },
    );
  }

  Future<void> _onToggleTask(ToggleTask event, Emitter<TasksState> emit) async {
    final result = await toggleTaskCompletion(ToggleTaskParams(taskId: event.taskId));
    
    result.fold(
      (failure) {
        log('Failed to toggle task: $failure');
        add(LoadTasks());
      },
      (_) {
        add(LoadTasks());
      },
    );
  }
}