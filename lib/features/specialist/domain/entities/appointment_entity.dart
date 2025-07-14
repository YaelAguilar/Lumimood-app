import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String professionalId;
  final DateTime date;
  final String time;
  final String reason;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.professionalId,
    required this.date,
    required this.time,
    required this.reason,
  });

  @override
  List<Object?> get props => [id, patientId, professionalId, date, time, reason];
}