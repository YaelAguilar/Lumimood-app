import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String professionalId;
  final DateTime date;
  final String time;
  final String reason;
  final String status;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.date,
    required this.time,
    required this.reason,
    this.status = 'scheduled',
  });

  @override
  List<Object?> get props => [id, patientId, patientName, professionalId, date, time, reason, status];
}