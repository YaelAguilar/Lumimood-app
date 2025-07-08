import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/note_model.dart';
import 'dart:developer';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc() : super(const NotesState()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    
    add(LoadNotes());
  }

  void _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) {
    emit(state.copyWith(status: NotesStatus.loading));
    
    final mockNotes = [
      Note(id: '1', title: 'Reflexión sobre la gratitud', date: DateTime(2024, 5, 20)),
      Note(id: '2', title: 'Ideas para el proyecto personal', date: DateTime(2024, 5, 18)),
      Note(id: '3', title: 'Resumen de la reunión de equipo', date: DateTime(2024, 5, 15)),
      Note(id: '4', title: 'Metas para la próxima semana', date: DateTime(2024, 5, 12)),
    ];

    emit(state.copyWith(status: NotesStatus.loaded, notes: mockNotes));
  }

  void _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    emit(state.copyWith(creationStatus: NoteCreationStatus.loading));
    log('Adding new note: ${event.title}');

    if (event.title.isEmpty || event.content.isEmpty) {
      emit(state.copyWith(creationStatus: NoteCreationStatus.error, errorMessage: 'El título y el contenido no pueden estar vacíos.'));
      emit(state.copyWith(creationStatus: NoteCreationStatus.initial, errorMessage: null));
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      date: DateTime.now(),
    );

    final updatedNotes = List<Note>.from(state.notes)..insert(0, newNote);
    
    emit(state.copyWith(
      creationStatus: NoteCreationStatus.success,
      notes: updatedNotes,
      status: NotesStatus.loaded,
    ));
    
    emit(state.copyWith(creationStatus: NoteCreationStatus.initial));
  }
}