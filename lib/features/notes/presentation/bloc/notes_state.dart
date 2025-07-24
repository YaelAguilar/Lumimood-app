part of 'notes_bloc.dart';

enum NotesStatus { initial, loading, loaded, error }
enum NoteCreationStatus { initial, loading, success, error }
enum NoteUpdateStatus { initial, loading, success, error }

class NotesState extends Equatable {
  final NotesStatus status;
  final List<Note> notes;
  final String? errorMessage;
  final NoteCreationStatus creationStatus;
  final NoteUpdateStatus updateStatus;

  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.errorMessage,
    this.creationStatus = NoteCreationStatus.initial,
    this.updateStatus = NoteUpdateStatus.initial,
  });

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    String? errorMessage,
    NoteCreationStatus? creationStatus,
    NoteUpdateStatus? updateStatus,
  }) {
    return NotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage ?? this.errorMessage,
      creationStatus: creationStatus ?? this.creationStatus,
      updateStatus: updateStatus ?? this.updateStatus,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage, creationStatus, updateStatus];
}