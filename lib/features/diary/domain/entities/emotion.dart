import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Emotion extends Equatable {
  final String name;
  final Color color;

  const Emotion({required this.name, required this.color});

  @override
  List<Object?> get props => [name, color];
}