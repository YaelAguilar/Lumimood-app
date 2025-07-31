part of 'observations_bloc.dart';

enum ObservationsStatus { initial, loading, loaded, error }
enum ObservationCreationStatus { initial, loading, success, error }

class ObservationsState extends Equatable {
  final ObservationsStatus status;
  final List<Observation> observations;
  final List<Observation> filteredObservations;
  final String? errorMessage;
  final ObservationCreationStatus creationStatus;
  final ObservationType? selectedType;
  final ObservationPriority? selectedPriority;

  const ObservationsState({
    this.status = ObservationsStatus.initial,
    this.observations = const [],
    this.filteredObservations = const [],
    this.errorMessage,
    this.creationStatus = ObservationCreationStatus.initial,
    this.selectedType,
    this.selectedPriority,
  });

  ObservationsState copyWith({
    ObservationsStatus? status,
    List<Observation>? observations,
    List<Observation>? filteredObservations,
    String? errorMessage,
    ObservationCreationStatus? creationStatus,
    ObservationType? selectedType,
    ObservationPriority? selectedPriority,
  }) {
    return ObservationsState(
      status: status ?? this.status,
      observations: observations ?? this.observations,
      filteredObservations: filteredObservations ?? this.filteredObservations,
      errorMessage: errorMessage,
      creationStatus: creationStatus ?? this.creationStatus,
      selectedType: selectedType ?? this.selectedType,
      selectedPriority: selectedPriority ?? this.selectedPriority,
    );
  }

  @override
  List<Object?> get props => [
        status,
        observations,
        filteredObservations,
        errorMessage,
        creationStatus,
        selectedType,
        selectedPriority,
      ];
}