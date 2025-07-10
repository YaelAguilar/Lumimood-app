import 'dart:developer';
import '../../../../core/error/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<void> addNote(NoteModel note);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final List<NoteModel> _cachedNotes = [
    NoteModel(id: '1', title: 'Reflexión sobre la gratitud', content: 'Hoy agradezco por...', date: DateTime(2024, 5, 20)),
    NoteModel(id: '2', title: 'Ideas para el proyecto personal', content: 'Implementar Clean Architecture...', date: DateTime(2024, 5, 18)),
    NoteModel(id: '3', title: 'Resumen de la reunión de equipo', content: 'Discutimos el sprint actual.', date: DateTime(2024, 5, 15)),
    NoteModel(id: '4', title: 'Metas para la próxima semana', content: '1. Terminar feature de notas.\n2. Ir al gimnasio.', date: DateTime(2024, 5, 12)),
  ];

  @override
  Future<List<NoteModel>> getNotes() async {
    log('DATA SOURCE: Fetching notes from local cache.');
    await Future.delayed(const Duration(milliseconds: 500));
    _cachedNotes.sort((a, b) => b.date.compareTo(a.date));
    return Future.value(List.from(_cachedNotes));
  }

  @override
  Future<void> addNote(NoteModel note) async {
    log('DATA SOURCE: Adding new note with title: ${note.title}');
    if (note.title.isEmpty || note.content.isEmpty) {
      throw CacheException();
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedNotes.add(note);
    return Future.value();
  }
}