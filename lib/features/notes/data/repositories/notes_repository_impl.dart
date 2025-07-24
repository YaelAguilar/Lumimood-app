import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource remoteDataSource;

  NotesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes(String patientId) async {
    try {
      final remoteNotes = await remoteDataSource.getNotes(patientId);
      return Right(remoteNotes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getNotesByDate(String patientId, String date) async {
    try {
      final remoteNotes = await remoteDataSource.getNotesByDate(patientId, date);
      return Right(remoteNotes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Note>> getNote(String noteId) async {
    try {
      final note = await remoteDataSource.getNote(noteId);
      return Right(note);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Note>> addNote({
    required String patientId,
    required String title,
    required String content,
  }) async {
    try {
      final newNote = NoteModel(
        id: '', // La API genera el ID
        patientId: patientId,
        title: title,
        content: content,
        date: DateTime.now(), // La API asigna la fecha
      );
      final createdNote = await remoteDataSource.addNote(newNote);
      return Right(createdNote);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote({
    required String noteId,
    required String content,
  }) async {
    try {
      final updatedNote = await remoteDataSource.updateNote(noteId, content);
      return Right(updatedNote);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await remoteDataSource.deleteNote(noteId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}