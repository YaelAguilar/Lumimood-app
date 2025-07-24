import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UpdateNote implements UseCase<Note, UpdateNoteParams> {
  final NotesRepository repository;

  UpdateNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(UpdateNoteParams params) async {
    return await repository.updateNote(
      noteId: params.noteId,
      content: params.content,
    );
  }
}

class UpdateNoteParams extends Equatable {
  final String noteId;
  final String content;

  const UpdateNoteParams({
    required this.noteId,
    required this.content,
  });

  @override
  List<Object?> get props => [noteId, content];
}