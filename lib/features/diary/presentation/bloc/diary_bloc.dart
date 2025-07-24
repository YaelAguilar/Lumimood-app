import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/usecases/get_notes.dart';
import '../../domain/entities/emotion.dart';
import '../../domain/usecases/get_emotions.dart';
import '../../domain/usecases/save_diary_entry.dart';

part 'diary_event.dart';
part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final GetEmotions getEmotions;
  final SaveDiaryEntry saveDiaryEntry;
  final GetNotes getNotes;
  final SessionCubit sessionCubit;

  DiaryBloc({
    required this.getEmotions,
    required this.saveDiaryEntry,
    required this.getNotes,
    required this.sessionCubit,
  }) : super(const DiaryState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<EmotionSelected>(_onEmotionSelected);
    on<IntensityChanged>(_onIntensityChanged);
    on<SaveEmotionButtonPressed>(_onSaveEmotionButtonPressed);

    add(LoadInitialData());
  }

  Future<void> _onLoadInitialData(LoadInitialData event, Emitter<DiaryState> emit) async {
    emit(state.copyWith(status: DiaryStatus.loading));
    
    try {
      final emotionsResult = await getEmotions(NoParams());
      
      await emotionsResult.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(state.copyWith(status: DiaryStatus.error, errorMessage: 'No se pudieron cargar las emociones.'));
          }
        },
        (emotions) async {
          // Load recent notes
          final sessionState = sessionCubit.state;
          if (sessionState is AuthenticatedSessionState) {
            final notesResult = await getNotes(GetNotesParams(patientId: sessionState.user.id));
            
            await notesResult.fold(
              (failure) async {
                if (!emit.isDone) {
                  emit(state.copyWith(
                    status: DiaryStatus.loaded, 
                    emotions: emotions,
                    recentNotes: [],
                  ));
                }
              },
              (notes) async {
                // Sort notes by date (most recent first) and get only the latest 3 notes
                final sortedNotes = List<Note>.from(notes)..sort((a, b) => b.date.compareTo(a.date));
                final recentNotes = sortedNotes.take(3).toList();
                if (!emit.isDone) {
                  emit(state.copyWith(
                    status: DiaryStatus.loaded, 
                    emotions: emotions,
                    recentNotes: recentNotes,
                  ));
                }
              },
            );
          } else {
            if (!emit.isDone) {
              emit(state.copyWith(
                status: DiaryStatus.loaded, 
                emotions: emotions,
                recentNotes: [],
              ));
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(status: DiaryStatus.error, errorMessage: 'Error inesperado: ${e.toString()}'));
      }
    }
  }

  void _onEmotionSelected(EmotionSelected event, Emitter<DiaryState> emit) {
    emit(state.copyWith(selectedEmotion: event.emotion));
  }

  void _onIntensityChanged(IntensityChanged event, Emitter<DiaryState> emit) {
    emit(state.copyWith(intensity: event.intensity));
  }

  Future<void> _onSaveEmotionButtonPressed(SaveEmotionButtonPressed event, Emitter<DiaryState> emit) async {
    if (sessionCubit.state is! AuthenticatedSessionState) {
      if (!emit.isDone) {
        emit(state.copyWith(isEmotionSaved: false, errorMessage: 'Usuario no autenticado.'));
      }
      return;
    }

    if (state.selectedEmotion == null) {
      if (!emit.isDone) {
        emit(state.copyWith(isEmotionSaved: false, errorMessage: 'Selecciona una emoción primero.'));
      }
      return;
    }

    final patientId = (sessionCubit.state as AuthenticatedSessionState).user.id;

    try {
      final result = await saveDiaryEntry(
        SaveDiaryParams(
          patientId: patientId,
          title: 'Registro de emoción',
          content: 'Emoción: ${state.selectedEmotion!.name} - Intensidad: ${state.intensity.round()}',
          emotion: state.selectedEmotion,
          intensity: state.intensity.round(),
        ),
      );

      await result.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(state.copyWith(isEmotionSaved: false, errorMessage: failure.message));
          }
        },
        (_) async {
          if (!emit.isDone) {
            emit(state.copyWith(isEmotionSaved: true));
            // Small delay to show the success message
            await Future.delayed(const Duration(milliseconds: 100));
            if (!emit.isDone) {
              emit(state.copyWith(isEmotionSaved: false)); // Reset flag
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(isEmotionSaved: false, errorMessage: 'Error inesperado: ${e.toString()}'));
      }
    }
  }
}