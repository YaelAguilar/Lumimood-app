part of 'tasks_bloc.dart';

sealed class TasksEvent {}

final class LoadTasks extends TasksEvent {}

final class ToggleTask extends TasksEvent {
  final String taskId;
  ToggleTask(this.taskId);
}

final class AddNewTask extends TasksEvent {
  final String title;
  AddNewTask(this.title);
}