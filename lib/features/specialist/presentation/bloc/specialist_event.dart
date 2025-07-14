part of 'specialist_bloc.dart';

sealed class SpecialistEvent extends Equatable {
  const SpecialistEvent();

  @override
  List<Object> get props => [];
}

class LoadSpecialistDashboard extends SpecialistEvent {}