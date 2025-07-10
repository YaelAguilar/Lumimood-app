import 'dart:developer';
import '../../../../core/error/exceptions.dart';
import '../models/diary_entry_model.dart';
import '../models/emotion_model.dart';

abstract class DiaryLocalDataSource {
  Future<List<EmotionModel>> getAvailableEmotions();
  Future<void> saveDiaryEntry(DiaryEntryModel entry);
}

class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  @override
  Future<List<EmotionModel>> getAvailableEmotions() async {
    log('DATA SOURCE: Fetching emotions from static list.');
    await Future.delayed(const Duration(milliseconds: 100));
    return Future.value(AppEmotions.emotions);
  }

  @override
  Future<void> saveDiaryEntry(DiaryEntryModel entry) async {
    log('DATA SOURCE: Simulating saving a diary entry to local storage.');
    log('Entry Title: ${entry.title}, Content: ${entry.content}, Emotion: ${entry.emotion?.name}');

    if (entry.title.isEmpty || entry.content.isEmpty) {
      throw CacheException();
    }

    await Future.delayed(const Duration(seconds: 1));
    return;
  }
}