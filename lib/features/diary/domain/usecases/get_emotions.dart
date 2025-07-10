import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/emotion.dart';
import '../repositories/diary_repository.dart';

class GetEmotions implements UseCase<List<Emotion>, NoParams> {
  final DiaryRepository repository;

  GetEmotions(this.repository);

  @override
  Future<Either<Failure, List<Emotion>>> call(NoParams params) async {
    return await repository.getAvailableEmotions();
  }
}