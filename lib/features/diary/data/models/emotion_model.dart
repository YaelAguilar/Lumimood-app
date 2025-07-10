import 'package:flutter/material.dart';
import '../../domain/entities/emotion.dart';

class EmotionModel extends Emotion {
  const EmotionModel({required super.name, required super.color});
}

class AppEmotions {
  static const List<EmotionModel> emotions = [
    EmotionModel(name: 'Feliz', color: Color(0xFFFFD700)),
    EmotionModel(name: 'Sorprendido', color: Color(0xFFFF8C00)),
    EmotionModel(name: 'Enojado', color: Color(0xFFFF4444)),
    EmotionModel(name: 'Con miedo', color: Color(0xFF9966CC)),
    EmotionModel(name: 'Triste', color: Color(0xFF4169E1)),
    EmotionModel(name: 'Disgustado', color: Color(0xFF228B22)),
  ];
}