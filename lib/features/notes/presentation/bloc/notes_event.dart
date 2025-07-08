part of 'notes_bloc.dart';

sealed class NotesEvent {}

final class LoadNotes extends NotesEvent {}

final class AddNote extends NotesEvent {
  final String title;
  final String content;
  AddNote({required this.title, required this.content});
}