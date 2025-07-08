import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final DateTime date;

  const Note({
    required this.id,
    required this.title,
    required this.date,
  });

  @override
  List<Object?> get props => [id, title, date];
}