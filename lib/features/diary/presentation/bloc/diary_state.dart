part of 'diary_bloc.dart';

enum DiaryStatus { initial, loading, loaded, error }

class DiaryState extends Equatable {
  final DiaryStatus status;
  final List<Emotion> emotions;
  final Emotion? selectedEmotion;
  final bool isNoteSaved;
  final String? errorMessage;

  const DiaryState({
    this.status = DiaryStatus.initial,
    this.emotions = const [],
    this.selectedEmotion,
    this.isNoteSaved = false,
    this.errorMessage,
  });

  DiaryState copyWith({
    DiaryStatus? status,
    List<Emotion>? emotions,
    Emotion? selectedEmotion,
    bool? isNoteSaved,
    String? errorMessage,
  }) {
    return DiaryState(
      status: status ?? this.status,
      emotions: emotions ?? this.emotions,
      selectedEmotion: selectedEmotion,
      isNoteSaved: isNoteSaved ?? this.isNoteSaved,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, emotions, selectedEmotion, isNoteSaved, errorMessage];
}