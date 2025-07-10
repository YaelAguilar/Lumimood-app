part of 'notes_bloc.dart';

sealed class NotesEvent {}

final class LoadNotes extends NotesEvent {}

final class AddNewNote extends NotesEvent {
  final String title;
  final String content;
  AddNewNote({required this.title, required this.content});
}