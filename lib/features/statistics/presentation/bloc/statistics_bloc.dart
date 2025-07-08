import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsBloc() : super(const StatisticsState()) {
    on<LoadStatisticsData>(_onLoadStatisticsData);

    add(LoadStatisticsData());
  }

  Future<void> _onLoadStatisticsData(LoadStatisticsData event, Emitter<StatisticsState> emit) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    
    await Future.delayed(const Duration(milliseconds: 800));

    emit(state.copyWith(
      status: StatisticsStatus.loaded,
      labels: ['Feliz', 'Sorpresa', 'Enojo', 'Miedo', 'Tristeza', 'Disgusto'],
      values: [8.5, 5.0, 3.2, 2.0, 6.8, 4.0],
    ));
  }
}