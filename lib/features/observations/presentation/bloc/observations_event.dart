part of 'observations_bloc.dart';

sealed class ObservationsEvent {}

final class LoadObservations extends ObservationsEvent {
  final String? patientId;
  LoadObservations({this.patientId});
}

final class AddNewObservation extends ObservationsEvent {
  final String patientId;
  final String content;
  final ObservationType type;
  final ObservationPriority priority;

  AddNewObservation({
    required this.patientId,
    required this.content,
    required this.type,
    required this.priority,
  });
}

final class FilterObservations extends ObservationsEvent {
  final ObservationType? type;
  final ObservationPriority? priority;

  FilterObservations({this.type, this.priority});
}