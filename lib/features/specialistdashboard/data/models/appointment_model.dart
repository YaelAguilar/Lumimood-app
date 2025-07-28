import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.professionalId,
    required super.date,
    required super.time,
    required super.reason,
    super.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['idAppointment'] ?? json['id'] ?? '',
      patientId: json['idPatient'] ?? json['patientId'] ?? '',
      patientName: json['patientName'] ?? 'Paciente',
      professionalId: json['idProfessional'] ?? json['professionalId'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'] ?? '',
      reason: json['reason'] ?? 'Sin motivo especificado',
      status: json['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAppointment': id,
      'idPatient': patientId,
      'patientName': patientName,
      'idProfessional': professionalId,
      'date': date.toIso8601String(),
      'time': time,
      'reason': reason,
      'status': status,
    };
  }
}