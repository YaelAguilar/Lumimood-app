import 'package:flutter/material.dart';
import '../../domain/entities/emotion.dart';

class EmotionModel extends Emotion {
  const EmotionModel({required super.name, required super.color});
}

class AppEmotions {
  // Las emociones se mapean a los nombres de la API
  static const List<EmotionModel> emotions = [
    EmotionModel(name: 'Felicidad', color: Color(0xFFFFD700)),
    EmotionModel(name: 'Tristeza', color: Color.fromARGB(255, 28, 99, 156)),
    EmotionModel(name: 'Ansiedad', color: Color(0xFFFF8C00)),
    EmotionModel(name: 'Enojo', color: Color(0xFFDC143C)),
    EmotionModel(name: 'Miedo', color: Color(0xFF483D8B)),
    EmotionModel(name: 'Calma', color: Color(0xFF20B2AA)),
    EmotionModel(name: 'Estrés', color: Color.fromARGB(255, 255, 90, 31)),
  ];
}