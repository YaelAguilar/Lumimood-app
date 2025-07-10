import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_statistics_data.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatisticsData getStatisticsData;

  StatisticsBloc({
    required this.getStatisticsData,
  }) : super(const StatisticsState()) {
    on<LoadStatisticsData>(_onLoadStatisticsData);
  }

  Future<void> _onLoadStatisticsData(LoadStatisticsData event, Emitter<StatisticsState> emit) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    final result = await getStatisticsData(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(status: StatisticsStatus.error, errorMessage: 'No se pudieron cargar los datos.')),
      (statistics) => emit(state.copyWith(
        status: StatisticsStatus.loaded,
        labels: statistics.labels,
        values: statistics.values,
      )),
    );
  }
}