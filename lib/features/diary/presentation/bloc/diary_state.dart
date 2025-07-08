part of 'diary_bloc.dart';

class DiaryState extends Equatable {
  final List<Emotion> emotions;
  final Emotion? selectedEmotion;
  final bool isNoteSaved;

  const DiaryState({
    this.emotions = const [],
    this.selectedEmotion,
    this.isNoteSaved = false,
  });

  DiaryState copyWith({
    List<Emotion>? emotions,
    Emotion? selectedEmotion,
    bool? isNoteSaved,
  }) {
    return DiaryState(
      emotions: emotions ?? this.emotions,
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      isNoteSaved: isNoteSaved ?? this.isNoteSaved,
    );
  }
  
  @override
  List<Object?> get props => [emotions, selectedEmotion, isNoteSaved];
}