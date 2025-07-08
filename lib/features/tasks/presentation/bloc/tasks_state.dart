part of 'tasks_bloc.dart';

enum TasksStatus { initial, loading, loaded, error }

class TasksState extends Equatable {
  final TasksStatus status;
  final List<Task> tasks;
  final String? errorMessage;

  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.errorMessage,
  });
  
  double get progress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? tasks,
    String? errorMessage,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}