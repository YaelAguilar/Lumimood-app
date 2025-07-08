part of 'diary_bloc.dart';

sealed class DiaryEvent {}

final class LoadInitialData extends DiaryEvent {}

final class EmotionSelected extends DiaryEvent {
  final Emotion emotion;
  EmotionSelected(this.emotion);
}

final class SaveNoteButtonPressed extends DiaryEvent {
  final String title;
  final String content;

  SaveNoteButtonPressed({required this.title, required this.content});
}