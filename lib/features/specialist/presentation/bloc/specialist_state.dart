part of 'specialist_bloc.dart';

enum SpecialistStatus { initial, loading, loaded, error }

class SpecialistState extends Equatable {
  final SpecialistStatus status;
  final List<AppointmentEntity> appointments;
  final String? errorMessage;

  const SpecialistState({
    this.status = SpecialistStatus.initial,
    this.appointments = const [],
    this.errorMessage,
  });

  SpecialistState copyWith({
    SpecialistStatus? status,
    List<AppointmentEntity>? appointments,
    String? errorMessage,
  }) {
    return SpecialistState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, appointments, errorMessage];
}