import '../../domain/entities/summary_entity.dart';

class SummaryModel extends SummaryEntity {
  const SummaryModel({
    required super.id,
    required super.patientId,
    required super.title,
    required super.content,
    required super.generatedAt,
    super.aiModel,
    super.analysedNotesCount,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
      aiModel: json['aiModel'] ?? 'AI Assistant',
      analysedNotesCount: json['analysedNotesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'title': title,
      'content': content,
      'generatedAt': generatedAt.toIso8601String(),
      'aiModel': aiModel,
      'analysedNotesCount': analysedNotesCount,
    };
  }
}