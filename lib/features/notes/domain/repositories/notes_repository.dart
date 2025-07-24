import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<Note>>> getNotes(String patientId);
  Future<Either<Failure, List<Note>>> getNotesByDate(String patientId, String date);
  Future<Either<Failure, Note>> getNote(String noteId);
  Future<Either<Failure, Note>> addNote({
    required String patientId,
    required String title,
    required String content,
  });
  Future<Either<Failure, Note>> updateNote({
    required String noteId,
    required String content,
  });
  Future<Either<Failure, void>> deleteNote(String noteId);
}