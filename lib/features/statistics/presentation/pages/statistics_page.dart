import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../bloc/statistics_bloc.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StatisticsBloc>()..add(LoadStatisticsData()),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryText, size: 30),
          onPressed: () => context.pop(),
        ),
        title: Text('Estadísticas', style: GoogleFonts.interTight(textStyle: textTheme.headlineMedium)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state.status == StatisticsStatus.loading || state.status == StatisticsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == StatisticsStatus.error) {
              return Center(child: Text(state.errorMessage ?? 'No se pudieron cargar los datos'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 40),
                        _buildChart(context, state.values, state.labels),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bienvenido', style: GoogleFonts.interTight(textStyle: textTheme.headlineSmall)),
                const SizedBox(height: 4),
                Text(
                  'Tu actividad reciente está de bajo.',
                  style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<double> values, List<String> labels) {
    final textTheme = Theme.of(context).textTheme;
    final bodySmallStyle = textTheme.bodySmall ?? const TextStyle(fontSize: 12);

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 10,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    if (value % 2 != 0 && value != 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(value.toInt().toString(), style: bodySmallStyle, textAlign: TextAlign.left);
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(labels[index], style: bodySmallStyle),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(
              values.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index],
                    color: AppTheme.primaryColor,
                    width: 16,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}