import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/entities/emotion.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_remote_datasource.dart';

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
      await remoteDataSource.saveNote(
        patientId: entry.idPatient,
        title: entry.title,
        content: entry.content,
      );
      if (entry.emotion != null) {
        await remoteDataSource.saveEmotion(
          patientId: entry.idPatient,
          emotionId: entry.emotion!.id,
          intensity: entry.intensity,
        );
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}