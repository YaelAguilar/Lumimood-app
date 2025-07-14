import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.patientId,
    required super.title,
    required super.content,
    required super.date,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['idRecNote'],
      patientId: json['idPatient'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPatient': patientId,
      'title': title,
      'content': content,
    };
  }
}