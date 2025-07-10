import 'package:flutter/material.dart';
import '../../domain/entities/diary_entry.dart';
import 'emotion_model.dart';

class DiaryEntryModel extends DiaryEntry {
  const DiaryEntryModel({
    required super.id,
    required super.title,
    required super.content,
    required super.date,
    super.emotion,
  });

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      emotion: json['emotion'] != null 
          ? EmotionModel(
              name: json['emotion']['name'], 
              color: Color(json['emotion']['color']) 
            ) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      // ignore: deprecated_member_use
      'emotion': emotion != null ? {'name': emotion!.name, 'color': emotion!.color.value} : null,
    };
  }
}