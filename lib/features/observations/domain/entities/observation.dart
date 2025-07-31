import 'package:equatable/equatable.dart';

class Observation extends Equatable {
  final String id;
  final String patientId;
  final String professionalId;
  final String professionalName;
  final String content;
  final DateTime date;
  final ObservationType type;
  final ObservationPriority priority;

  const Observation({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.professionalName,
    required this.content,
    required this.date,
    this.type = ObservationType.general,
    this.priority = ObservationPriority.normal,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        professionalId,
        professionalName,
        content,
        date,
        type,
        priority,
      ];
}

enum ObservationType {
  general,
  progress,
  concern,
  recommendation,
}

enum ObservationPriority {
  low,
  normal,
  high,
}

extension ObservationTypeExtension on ObservationType {
  String get displayName {
    switch (this) {
      case ObservationType.general:
        return 'General';
      case ObservationType.progress:
        return 'Progreso';
      case ObservationType.concern:
        return 'Preocupación';
      case ObservationType.recommendation:
        return 'Recomendación';
    }
  }

  IconData get icon {
    switch (this) {
      case ObservationType.general:
        return Icons.note_outlined;
      case ObservationType.progress:
        return Icons.trending_up;
      case ObservationType.concern:
        return Icons.warning_amber_outlined;
      case ObservationType.recommendation:
        return Icons.lightbulb_outline;
    }
  }

  Color get color {
    switch (this) {
      case ObservationType.general:
        return Colors.blue;
      case ObservationType.progress:
        return Colors.green;
      case ObservationType.concern:
        return Colors.orange;
      case ObservationType.recommendation:
        return Colors.purple;
    }
  }
}

extension ObservationPriorityExtension on ObservationPriority {
  String get displayName {
    switch (this) {
      case ObservationPriority.low:
        return 'Baja';
      case ObservationPriority.normal:
        return 'Normal';
      case ObservationPriority.high:
        return 'Alta';
    }
  }

  Color get color {
    switch (this) {
      case ObservationPriority.low:
        return Colors.grey;
      case ObservationPriority.normal:
        return Colors.blue;
      case ObservationPriority.high:
        return Colors.red;
    }
  }
}