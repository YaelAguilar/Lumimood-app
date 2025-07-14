import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class GetNotes implements UseCase<List<Note>, GetNotesParams> {
  final NotesRepository repository;

  GetNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(GetNotesParams params) async {
    return await repository.getNotes(params.patientId);
  }
}

class GetNotesParams extends Equatable {
  final String patientId;
  const GetNotesParams({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}