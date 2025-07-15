import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
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
      log('📝 NOTES BLOC: Patient ID found - ${state.user.id}');
      return state.user.id;
    }
    log('❌ NOTES BLOC: No authenticated user found');
    return null;
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    log('📝 NOTES BLOC: LoadNotes event received');
    
    final patientId = _patientId;
    if (patientId == null) {
      log('❌ NOTES BLOC: Cannot load notes - no patient ID');
      emit(state.copyWith(
        status: NotesStatus.error, 
        errorMessage: 'Usuario no autenticado'
      ));
      return;
    }

    log('📝 NOTES BLOC: Loading notes for patient: $patientId');
    emit(state.copyWith(status: NotesStatus.loading));
    
    try {
      final result = await getNotes(GetNotesParams(patientId: patientId));

      result.fold(
        (failure) {
          log('❌ NOTES BLOC: Failed to load notes - ${failure.message}');
          emit(state.copyWith(
            status: NotesStatus.error, 
            errorMessage: failure.message
          ));
        },
        (notes) {
          log('✅ NOTES BLOC: Successfully loaded ${notes.length} notes');
          for (int i = 0; i < notes.length; i++) {
            log('📝 NOTES BLOC: Note ${i + 1}: "${notes[i].title}" (${notes[i].date})');
          }
          emit(state.copyWith(
            status: NotesStatus.loaded, 
            notes: notes,
            errorMessage: null
          ));
        },
      );
    } catch (e) {
      log('💥 NOTES BLOC: Unexpected error loading notes - $e');
      emit(state.copyWith(
        status: NotesStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}'
      ));
    }
  }

  Future<void> _onAddNewNote(AddNewNote event, Emitter<NotesState> emit) async {
    log('📝 NOTES BLOC: AddNewNote event received - Title: "${event.title}"');
    
    final patientId = _patientId;
    if (patientId == null) {
      log('❌ NOTES BLOC: Cannot add note - no patient ID');
      emit(state.copyWith(
        creationStatus: NoteCreationStatus.error,
        errorMessage: 'Usuario no autenticado'
      ));
      return;
    }

    if (event.title.trim().isEmpty && event.content.trim().isEmpty) {
      log('❌ NOTES BLOC: Cannot add note - title and content are empty');
      emit(state.copyWith(
        creationStatus: NoteCreationStatus.error,
        errorMessage: 'La nota debe tener al menos un título o contenido'
      ));
      return;
    }

    log('📝 NOTES BLOC: Adding note for patient: $patientId');
    emit(state.copyWith(creationStatus: NoteCreationStatus.loading));
    
    try {
      final result = await addNote(AddNoteParams(
        patientId: patientId,
        title: event.title.trim().isNotEmpty ? event.title.trim() : 'Sin título',
        content: event.content.trim(),
      ));

      result.fold(
        (failure) {
          log('❌ NOTES BLOC: Failed to add note - ${failure.message}');
          emit(state.copyWith(
            creationStatus: NoteCreationStatus.error,
            errorMessage: failure.message,
          ));
        },
        (_) {
          log('✅ NOTES BLOC: Note added successfully, reloading notes...');
          emit(state.copyWith(creationStatus: NoteCreationStatus.success));
          // Recargar las notas después de agregar una nueva
          add(LoadNotes());
        },
      );
    } catch (e) {
      log('💥 NOTES BLOC: Unexpected error adding note - $e');
      emit(state.copyWith(
        creationStatus: NoteCreationStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}'
      ));
    }
    
    // Reset creation status después de un tiempo
    await Future.delayed(const Duration(milliseconds: 500));
    if (!isClosed) {
      emit(state.copyWith(creationStatus: NoteCreationStatus.initial));
    }
  }
}