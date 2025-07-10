import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

class SaveDiaryEntry implements UseCase<void, SaveDiaryParams> {
  final DiaryRepository repository;

  SaveDiaryEntry(this.repository);
  
  @override
  Future<Either<Failure, void>> call(SaveDiaryParams params) async {
    final newEntry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: params.title,
      content: params.content,
      date: DateTime.now(),
      emotion: params.emotion,
    );
    return await repository.saveDiaryEntry(newEntry);
  }
}

class SaveDiaryParams extends Equatable {
  final String title;
  final String content;
  final dynamic emotion;

  const SaveDiaryParams({
    required this.title,
    required this.content,
    this.emotion,
  });

  @override
  List<Object?> get props => [title, content, emotion];
}