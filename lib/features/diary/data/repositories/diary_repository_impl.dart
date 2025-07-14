import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/emotion.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_remote_datasource.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryRemoteDataSource remoteDataSource;

  DiaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Emotion>>> getAvailableEmotions() async {
    try {
      final emotionModels = await remoteDataSource.getAvailableEmotions();
      return Right(emotionModels);
    } on Exception {
      return const Left(CacheFailure('Could not fetch emotions'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDiaryEntry(DiaryEntry entry) async {
    try {
      final diaryEntryModel = DiaryEntryModel(
        id: entry.id,
        idPatient: entry.idPatient,
        title: entry.title,
        content: entry.content,
        date: entry.date,
        emotion: entry.emotion,
        intensity: entry.intensity,
      );
      await remoteDataSource.saveDiaryEntry(diaryEntryModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}