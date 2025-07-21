import 'package:equatable/equatable.dart';
import 'emotion.dart';

class DiaryEntry extends Equatable {
  final String id;
  final String idPatient;
  final String title;
  final String content;
  final DateTime date;
  final Emotion? emotion;
  final int intensity;

  const DiaryEntry({
    this.id = '',
    required this.idPatient,
    required this.title,
    required this.content,
    required this.date,
    this.emotion,
    this.intensity = 5,
  });
  
  @override
  List<Object?> get props => [id, idPatient, title, content, date, emotion, intensity];
}