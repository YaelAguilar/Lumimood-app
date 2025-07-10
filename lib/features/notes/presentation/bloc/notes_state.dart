part of 'notes_bloc.dart';

enum NotesStatus { initial, loading, loaded, error }
enum NoteCreationStatus { initial, loading, success, error }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final String? errorMessage;
  final NoteCreationStatus creationStatus;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.errorMessage,
    this.creationStatus = NoteCreationStatus.initial,
  });

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? errorMessage,
    NoteCreationStatus? creationStatus,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
      creationStatus: creationStatus ?? this.creationStatus,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage, creationStatus];
}