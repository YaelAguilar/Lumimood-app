import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/emotion_model.dart';

part 'diary_event.dart';
part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  DiaryBloc() : super(const DiaryState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<EmotionSelected>(_onEmotionSelected);
    on<SaveNoteButtonPressed>(_onSaveNoteButtonPressed);

    add(LoadInitialData());
  }

  void _onLoadInitialData(LoadInitialData event, Emitter<DiaryState> emit) {
    emit(state.copyWith(emotions: AppEmotions.emotions));
  }

  void _onEmotionSelected(EmotionSelected event, Emitter<DiaryState> emit) {
    emit(state.copyWith(selectedEmotion: event.emotion));
  }

  void _onSaveNoteButtonPressed(SaveNoteButtonPressed event, Emitter<DiaryState> emit) {
    if (event.title.isEmpty || event.content.isEmpty) {
      log('El título o el contenido están vacíos.');
      return;
    }

    log('Guardando nota en el BLoC...');
    log('Título: ${event.title}');
    log('Contenido: ${event.content}');
    log('Emoción seleccionada: ${state.selectedEmotion?.name ?? "Ninguna"}');

    emit(state.copyWith(isNoteSaved: true));
    emit(state.copyWith(isNoteSaved: false));
  }
}