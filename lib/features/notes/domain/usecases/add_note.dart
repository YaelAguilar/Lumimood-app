import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notes_repository.dart';

class AddNote implements UseCase<void, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, void>> call(AddNoteParams params) async {
    return await repository.addNote(title: params.title, content: params.content);
  }
}

class AddNoteParams extends Equatable {
  final String title;
  final String content;

  const AddNoteParams({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}