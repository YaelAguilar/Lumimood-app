import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotes getNotes;
  final AddNote addNote;
  final SessionCubit sessionCubit;

  NotesBloc({
    required this.getNotes,
    required this.addNote,
    required this.sessionCubit,
  }) : super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNewNote>(_onAddNewNote);
  }

  String? get _patientId {
    final state = sessionCubit.state;
    if (state is AuthenticatedSessionState) {
      return state.user.id;
    }
    return null;
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    if (_patientId == null) return;
    emit(state.copyWith(status: NotesStatus.loading));
    final result = await getNotes(GetNotesParams(patientId: _patientId!));

    result.fold(
      (failure) => emit(state.copyWith(status: NotesStatus.error, errorMessage: failure.message)),
      (notes) => emit(state.copyWith(status: NotesStatus.loaded, notes: notes)),
    );
  }

  Future<void> _onAddNewNote(AddNewNote event, Emitter<NotesState> emit) async {
    if (_patientId == null) return;
    emit(state.copyWith(creationStatus: NoteCreationStatus.loading));
    
    final result = await addNote(AddNoteParams(
      patientId: _patientId!,
      title: event.title,
      content: event.content,
    ));

    result.fold(
      (failure) {
        emit(state.copyWith(
          creationStatus: NoteCreationStatus.error,
          errorMessage: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(creationStatus: NoteCreationStatus.success));
        add(LoadNotes());
      },
    );
    emit(state.copyWith(creationStatus: NoteCreationStatus.initial));
  }
}