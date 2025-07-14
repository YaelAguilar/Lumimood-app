import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';
import '../../domain/usecases/get_statistics_data.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatisticsData getStatisticsData;
  final SessionCubit sessionCubit;

  StatisticsBloc({
    required this.getStatisticsData,
    required this.sessionCubit,
  }) : super(const StatisticsState()) {
    on<LoadStatisticsData>(_onLoadStatisticsData);
  }

  Future<void> _onLoadStatisticsData(LoadStatisticsData event, Emitter<StatisticsState> emit) async {
    final state = sessionCubit.state;
    if (state is! AuthenticatedSessionState) return;

    emit(this.state.copyWith(status: StatisticsStatus.loading));
    final result = await getStatisticsData(
      GetStatisticsParams(patientId: state.user.id, date: DateTime.now()),
    );

    result.fold(
      (failure) => emit(this.state.copyWith(status: StatisticsStatus.error, errorMessage: failure.message)),
      (statistics) => emit(this.state.copyWith(
        status: StatisticsStatus.loaded,
        labels: statistics.labels,
        values: statistics.values,
      )),
    );
  }
}