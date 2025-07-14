import '../../domain/entities/diary_entry.dart';
// import 'emotion_model.dart'; // -> Eliminado

class DiaryEntryModel extends DiaryEntry {
  const DiaryEntryModel({
    required super.id,
    required super.idPatient,
    required super.title,
    required super.content,
    required super.date,
    super.emotion,
    super.intensity,
  });

  // La API no devuelve una entrada combinada, así que no necesitamos fromJson por ahora.

  Map<String, dynamic> toNoteJson() {
    return {
      'idPatient': idPatient,
      'title': title,
      'content': content,
    };
  }

  Map<String, dynamic> toEmotionJson() {
    return {
      'idPatient': idPatient,
      'emotionName': emotion!.name.toLowerCase(),
      'intensity': intensity,
    };
  }
}