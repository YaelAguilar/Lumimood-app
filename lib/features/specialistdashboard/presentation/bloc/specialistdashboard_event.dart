part of 'specialistdashboard_bloc.dart';

sealed class SpecialistDashboardEvent extends Equatable {
  const SpecialistDashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends SpecialistDashboardEvent {}

class LoadAllPatients extends SpecialistDashboardEvent {}

class LoadPatients extends SpecialistDashboardEvent {}

class ChangeSelectedDate extends SpecialistDashboardEvent {
  final DateTime date;
  
  const ChangeSelectedDate(this.date);
  
  @override
  List<Object> get props => [date];
}

class RefreshDashboard extends SpecialistDashboardEvent {}