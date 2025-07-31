import 'package:equatable/equatable.dart';

class SummaryEntity extends Equatable {
  final String id;
  final String patientId;
  final String title;
  final String content;
  final DateTime generatedAt;
  final String aiModel;
  final int analysedNotesCount;

  const SummaryEntity({
    required this.id,
    required this.patientId,
    required this.title,
    required this.content,
    required this.generatedAt,
    this.aiModel = 'AI Assistant',
    this.analysedNotesCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        title,
        content,
        generatedAt,
        aiModel,
        analysedNotesCount,
      ];
}