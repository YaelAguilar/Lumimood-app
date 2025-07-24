/*import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/diary_entry.dart';
import '../entities/emotion.dart';
import '../repositories/diary_repository.dart';

class SaveDiaryEntry implements UseCase<void, SaveDiaryParams> {
  final DiaryRepository repository;

  SaveDiaryEntry(this.repository);
  
  @override
  Future<Either<Failure, void>> call(SaveDiaryParams params) async {
    final newEntry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idPatient: params.patientId,
      title: params.title,
      content: params.content,
      date: DateTime.now(),
      emotion: params.emotion,
      intensity: params.intensity,
    );
    return repository.saveDiaryEntry(newEntry);
  }
}

class SaveDiaryParams extends Equatable {
  final String patientId;
  final String title;
  final String content;
  final Emotion? emotion;
  final int intensity;

  const SaveDiaryParams({
    required this.patientId,
    required this.title,
    required this.content,
    this.emotion,
    required this.intensity,
  });

  @override
  List<Object?> get props => [patientId, title, content, emotion, intensity];
}*/