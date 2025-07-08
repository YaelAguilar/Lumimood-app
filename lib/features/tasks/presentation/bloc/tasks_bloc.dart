import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc() : super(const TasksState()) {
    on<LoadTasks>(_onLoadTasks);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<AddTask>(_onAddTask);

    add(LoadTasks());
  }

  void _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) {
    emit(state.copyWith(status: TasksStatus.loading));
    
    final mockTasks = [
      const Task(id: '1', title: 'Hacer ejercicio 30 minutos'),
      const Task(id: '2', title: 'Meditar por 10 minutos', isCompleted: true),
      const Task(id: '3', title: 'Escribir en el diario'),
      const Task(id: '4', title: 'Leer un capítulo de un libro', isCompleted: true),
      const Task(id: '5', title: 'Planificar el día de mañana'),
    ];

    emit(state.copyWith(status: TasksStatus.loaded, tasks: mockTasks));
  }

  void _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TasksState> emit) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedTasks));
  }

  void _onAddTask(AddTask event, Emitter<TasksState> emit) {
    if (event.title.isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
    );

    final updatedTasks = List<Task>.from(state.tasks)..add(newTask);
    emit(state.copyWith(tasks: updatedTasks));
  }
}