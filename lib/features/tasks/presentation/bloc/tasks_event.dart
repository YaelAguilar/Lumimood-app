part of 'tasks_bloc.dart';

sealed class TasksEvent {}

final class LoadTasks extends TasksEvent {}

final class ToggleTaskCompletion extends TasksEvent {
  final String taskId;
  ToggleTaskCompletion(this.taskId);
}

final class AddTask extends TasksEvent {
  final String title;
  AddTask(this.title);
}