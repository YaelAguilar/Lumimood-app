import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class AddNote implements UseCase<Note, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(AddNoteParams params) async {
    return await repository.addNote(
      patientId: params.patientId,
      title: params.title,
      content: params.content,
    );
  }
}

class AddNoteParams extends Equatable {
  final String patientId;
  final String title;
  final String content;

  const AddNoteParams({
    required this.patientId,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [patientId, title, content];
}