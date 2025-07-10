import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';

abstract class NotesRepository {
  Future<Either<Failure, List<Note>>> getNotes();
  Future<Either<Failure, void>> addNote({
    required String title,
    required String content,
  });
}