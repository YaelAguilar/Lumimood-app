import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/emotion.dart';

abstract class DiaryRepository {
  Future<Either<Failure, List<Emotion>>> getAvailableEmotions();
  Future<Either<Failure, void>> saveEmotion({
    required String patientId,
    required String emotionName,
    required int intensity,
  });
}