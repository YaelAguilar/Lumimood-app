import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/emotion.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_local_datasource.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource localDataSource;

  DiaryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Emotion>>> getAvailableEmotions() async {
    try {
      final emotionModels = await localDataSource.getAvailableEmotions();
      return Right(emotionModels);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveDiaryEntry(DiaryEntry entry) async {
    try {
      final diaryEntryModel = DiaryEntryModel(
        id: entry.id,
        title: entry.title,
        content: entry.content,
        date: entry.date,
        emotion: entry.emotion,
      );
      await localDataSource.saveDiaryEntry(diaryEntryModel);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}