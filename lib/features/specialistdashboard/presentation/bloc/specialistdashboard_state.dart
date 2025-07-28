part of 'specialistdashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

class SpecialistDashboardState extends Equatable {
  final DashboardStatus status;
  final List<AppointmentEntity> appointments;
  final DateTime selectedDate;
  final String? professionalName;
  final String? errorMessage;

  SpecialistDashboardState({
    this.status = DashboardStatus.initial,
    this.appointments = const [],
    DateTime? selectedDate,
    this.professionalName,
    this.errorMessage,
  }) : selectedDate = selectedDate ?? DateTime.now();

  int get todayAppointmentsCount => appointments.length;
  
  int get completedAppointmentsCount => 
    appointments.where((a) => a.status == 'completed').length;
    
  int get pendingAppointmentsCount => 
    appointments.where((a) => a.status == 'scheduled').length;

  SpecialistDashboardState copyWith({
    DashboardStatus? status,
    List<AppointmentEntity>? appointments,
    DateTime? selectedDate,
    String? professionalName,
    String? errorMessage,
  }) {
    return SpecialistDashboardState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      selectedDate: selectedDate ?? this.selectedDate,
      professionalName: professionalName ?? this.professionalName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, appointments, selectedDate, professionalName, errorMessage];
}