import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String patientId;
  final String title;
  final String content;
  final DateTime date;

  const Note({
    required this.id,
    required this.patientId,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  List<Object?> get props => [id, patientId, title, content, date];
}