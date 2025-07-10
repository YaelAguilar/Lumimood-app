import 'package:equatable/equatable.dart';
import 'emotion.dart';

class DiaryEntry extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final Emotion? emotion;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.emotion,
  });
  
  @override
  List<Object?> get props => [id, title, content, date, emotion];
}