part of 'diary_bloc.dart';

enum DiaryStatus { initial, loading, loaded, error }

class DiaryState extends Equatable {
  final DiaryStatus status;
  final List<Emotion> emotions;
  final Emotion? selectedEmotion;
  final double intensity;
  final bool isNoteSaved;
  final String? errorMessage;

  const DiaryState({
    this.status = DiaryStatus.initial,
    this.emotions = const [],
    this.selectedEmotion,
    this.intensity = 5.0,
    this.isNoteSaved = false,
    this.errorMessage,
  });

  DiaryState copyWith({
    DiaryStatus? status,
    List<Emotion>? emotions,
    Emotion? selectedEmotion,
    double? intensity,
    bool? isNoteSaved,
    String? errorMessage,
  }) {
    return DiaryState(
      status: status ?? this.status,
      emotions: emotions ?? this.emotions,
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      intensity: intensity ?? this.intensity,
      isNoteSaved: isNoteSaved ?? this.isNoteSaved,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, emotions, selectedEmotion, intensity, isNoteSaved, errorMessage];
}