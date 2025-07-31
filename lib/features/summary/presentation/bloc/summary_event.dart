part of 'summary_bloc.dart';

sealed class SummaryEvent {}

final class LoadSummary extends SummaryEvent {}

final class LoadSummaryForPatient extends SummaryEvent {
  final String patientId;
  LoadSummaryForPatient({required this.patientId});
}