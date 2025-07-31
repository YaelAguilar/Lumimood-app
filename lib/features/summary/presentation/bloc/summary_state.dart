part of 'summary_bloc.dart';

enum SummaryStatus { initial, loading, loaded, error }

class SummaryState extends Equatable {
  final SummaryStatus status;
  final SummaryEntity? summary;
  final String? errorMessage;

  const SummaryState({
    this.status = SummaryStatus.initial,
    this.summary,
    this.errorMessage,
  });

  SummaryState copyWith({
    SummaryStatus? status,
    SummaryEntity? summary,
    String? errorMessage,
  }) {
    return SummaryState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}