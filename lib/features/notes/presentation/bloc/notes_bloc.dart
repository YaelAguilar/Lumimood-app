import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotes getNotes;
  final AddNote addNote;

  NotesBloc({
    required this.getNotes,
    required this.addNote,
  }) : super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNewNote>(_onAddNewNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(state.copyWith(status: NotesStatus.loading));
    final result = await getNotes(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(status: NotesStatus.error, errorMessage: 'No se pudieron cargar las notas.')),
      (notes) => emit(state.copyWith(status: NotesStatus.loaded, notes: notes)),
    );
  }

  Future<void> _onAddNewNote(AddNewNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(creationStatus: NoteCreationStatus.loading));
    
    final result = await addNote(AddNoteParams(title: event.title, content: event.content));

    result.fold(
      (failure) {
        emit(state.copyWith(
          creationStatus: NoteCreationStatus.error,
          errorMessage: 'El título y el contenido no pueden estar vacíos.',
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