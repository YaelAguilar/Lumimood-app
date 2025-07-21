import 'package:flutter/material.dart';
import '../../domain/entities/emotion.dart';

class EmotionModel extends Emotion {
  const EmotionModel({
    required super.id,
    required super.name,
    required super.color
  });
}

class AppEmotions {
  static const List<EmotionModel> emotions = [
    EmotionModel(id: 'felicidad', name: 'Felicidad', color: Color(0xFFFFD700)),
    EmotionModel(id: 'tristeza', name: 'Tristeza', color: Color.fromARGB(255, 28, 99, 156)),
    EmotionModel(id: 'ansiedad', name: 'Ansiedad', color: Color(0xFFFF8C00)),
    EmotionModel(id: 'enojo', name: 'Enojo', color: Color(0xFFDC143C)),
    EmotionModel(id: 'miedo', name: 'Miedo', color: Color(0xFF483D8B)),
    EmotionModel(id: 'calma', name: 'Calma', color: Color(0xFF20B2AA)),
    EmotionModel(id: 'estres', name: 'Estrés', color: Color.fromARGB(255, 255, 90, 31)),
  ];
}