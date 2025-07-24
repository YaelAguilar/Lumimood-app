import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/diary_repository.dart';

class SaveEmotion implements UseCase<void, SaveEmotionParams> {
  final DiaryRepository repository;

  SaveEmotion(this.repository);
  
  @override
  Future<Either<Failure, void>> call(SaveEmotionParams params) async {
    return repository.saveEmotion(
      patientId: params.patientId,
      emotionName: params.emotionName,
      intensity: params.intensity,
    );
  }
}

class SaveEmotionParams extends Equatable {
  final String patientId;
  final String emotionName;
  final int intensity;

  const SaveEmotionParams({
    required this.patientId,
    required this.emotionName,
    required this.intensity,
  });

  @override
  List<Object?> get props => [patientId, emotionName, intensity];
}