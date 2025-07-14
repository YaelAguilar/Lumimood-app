import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.professionalId,
    required super.date,
    required super.time,
    required super.reason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['idAppointment'],
      patientId: json['idPatient'],
      professionalId: json['idProfessional'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      reason: json['reason'],
    );
  }
}