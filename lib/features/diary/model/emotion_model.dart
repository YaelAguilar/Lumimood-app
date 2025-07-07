import 'package:flutter/material.dart';

class Emotion {
  final String name;
  final Color color;

  const Emotion({required this.name, required this.color});
}

class AppEmotions {
  static const List<Emotion> emotions = [
    Emotion(name: 'Feliz', color: Color(0xFFFFD700)),
    Emotion(name: 'Sorprendido', color: Color(0xFFFF8C00)),
    Emotion(name: 'Enojado', color: Color(0xFFFF4444)),
    Emotion(name: 'Con miedo', color: Color(0xFF9966CC)),
    Emotion(name: 'Triste', color: Color(0xFF4169E1)),
    Emotion(name: 'Disgustado', color: Color(0xFF228B22)),
  ];
}