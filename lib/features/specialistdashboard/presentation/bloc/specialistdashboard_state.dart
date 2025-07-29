part of 'specialistdashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }
enum PatientsStatus { initial, loading, loaded, error }

class SpecialistDashboardState extends Equatable {
  final DashboardStatus status;
  final PatientsStatus patientsStatus;
  final List<AppointmentEntity> appointments;
  final List<PatientEntity> patients;
  final DateTime selectedDate;
  final String? professionalName;
  final String? professionalId;
  final String? errorMessage;

  SpecialistDashboardState({
    this.status = DashboardStatus.initial,
    this.patientsStatus = PatientsStatus.initial,
    this.appointments = const [],
    this.patients = const [],
    DateTime? selectedDate,
    this.professionalName,
    this.professionalId,
    this.errorMessage,
  }) : selectedDate = selectedDate ?? DateTime.now();

  int get todayAppointmentsCount => appointments.length;
  
  int get completedAppointmentsCount => 
    appointments.where((a) => a.status == 'completed').length;
    
  int get pendingAppointmentsCount => 
    appointments.where((a) => a.status == 'scheduled').length;

  int get totalPatientsCount => patients.length;

  SpecialistDashboardState copyWith({
    DashboardStatus? status,
    PatientsStatus? patientsStatus,
    List<AppointmentEntity>? appointments,
    List<PatientEntity>? patients,
    DateTime? selectedDate,
    String? professionalName,
    String? professionalId,
    String? errorMessage,
  }) {
    return SpecialistDashboardState(
      status: status ?? this.status,
      patientsStatus: patientsStatus ?? this.patientsStatus,
      appointments: appointments ?? this.appointments,
      patients: patients ?? this.patients,
      selectedDate: selectedDate ?? this.selectedDate,
      professionalName: professionalName ?? this.professionalName,
      professionalId: professionalId ?? this.professionalId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, 
        patientsStatus, 
        appointments, 
        patients, 
        selectedDate, 
        professionalName, 
        professionalId, 
        errorMessage
      ];
}