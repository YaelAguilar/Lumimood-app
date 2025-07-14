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
  Future<Either<Failure, void>> addNote({
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
      await remoteDataSource.addNote(newNote);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}