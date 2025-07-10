import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/emotion.dart';
import '../../domain/usecases/get_emotions.dart';
import '../../domain/usecases/save_diary_entry.dart';

part 'diary_event.dart';
part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final GetEmotions getEmotions;
  final SaveDiaryEntry saveDiaryEntry;

  DiaryBloc({
    required this.getEmotions,
    required this.saveDiaryEntry,
  }) : super(const DiaryState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<EmotionSelected>(_onEmotionSelected);
    on<SaveNoteButtonPressed>(_onSaveNoteButtonPressed);

    add(LoadInitialData());
  }

  Future<void> _onLoadInitialData(LoadInitialData event, Emitter<DiaryState> emit) async {
    emit(state.copyWith(status: DiaryStatus.loading));
    final result = await getEmotions(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(status: DiaryStatus.error, errorMessage: 'No se pudieron cargar las emociones.')),
      (emotions) => emit(state.copyWith(status: DiaryStatus.loaded, emotions: emotions)),
    );
  }

  void _onEmotionSelected(EmotionSelected event, Emitter<DiaryState> emit) {
    emit(state.copyWith(selectedEmotion: event.emotion));
  }

  Future<void> _onSaveNoteButtonPressed(SaveNoteButtonPressed event, Emitter<DiaryState> emit) async {
    final result = await saveDiaryEntry(
      SaveDiaryParams(
        title: event.title,
        content: event.content,
        emotion: state.selectedEmotion,
      ),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isNoteSaved: false));
      },
      (_) {
        emit(state.copyWith(isNoteSaved: true));
        emit(state.copyWith(isNoteSaved: false));
      },
    );
  }
}