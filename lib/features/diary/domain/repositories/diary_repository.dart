import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../entities/emotion.dart';

abstract class DiaryRepository {
  Future<Either<Failure, List<Emotion>>> getAvailableEmotions();
  Future<Either<Failure, void>> saveDiaryEntry(DiaryEntry entry);
}