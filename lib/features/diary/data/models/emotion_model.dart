import 'package:flutter/material.dart';
import '../../domain/entities/emotion.dart';

class EmotionModel extends Emotion {
  const EmotionModel({required super.name, required super.color});
}

class AppEmotions {
  // Las emociones se mapean a los nombres de la API
  static const List<EmotionModel> emotions = [
    EmotionModel(name: 'Felicidad', color: Color(0xFFFFD700)),
    EmotionModel(name: 'Tristeza', color: Color(0xFF4169E1)),
    EmotionModel(name: 'Ansiedad', color: Color(0xFF9966CC)),
    EmotionModel(name: 'Enojo', color: Color(0xFFFF4444)),
    EmotionModel(name: 'Miedo', color: Color(0xFF9966CC)),
    EmotionModel(name: 'Calma', color: Color(0xFF228B22)),
    EmotionModel(name: 'Estrés', color: Color(0xFFFF8C00)),
  ];
}