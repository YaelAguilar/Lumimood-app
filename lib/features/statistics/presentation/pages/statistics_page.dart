import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AnimatedBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                elevation: 0,
                backgroundColor: AppTheme.scaffoldBackground.withAlpha(200),
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryText, size: 20),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Mis Estadísticas',
                  style: GoogleFonts.interTight(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<StatisticsBloc, StatisticsState>(
                  builder: (context, state) {
                    if (state.status == StatisticsStatus.loading || state.status == StatisticsStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state.status == StatisticsStatus.error) {
                      return Center(child: Text(state.errorMessage ?? 'Error al cargar datos'));
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          _SummaryCard(labels: state.labels, values: state.values),
                          const SizedBox(height: 24),
                          _ChartCard(values: state.values, labels: state.labels),
                          const SizedBox(height: 24),
                          const _InsightsCard(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<String> labels;
  final List<double> values;

  const _SummaryCard({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty || values.isEmpty) return const SizedBox.shrink();

    double maxValue = -1;
    String predominantEmotion = '';
    double minValue = double.infinity;
    String lessFrequentEmotion = '';

    for (int i = 0; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        predominantEmotion = labels[i];
      }
      if (values[i] < minValue) {
        minValue = values[i];
        lessFrequentEmotion = labels[i];
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              icon: Icons.favorite_rounded,
              color: AppTheme.primaryColor,
              label: 'Emoción Predominante',
              value: predominantEmotion,
            ),
            _SummaryItem(
              icon: Icons.sentiment_neutral_rounded,
              color: Colors.orange.shade300,
              label: 'Menos Frecuente',
              value: lessFrequentEmotion,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppTheme.primaryText.withAlpha(150)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.interTight(
            textStyle: textTheme.titleMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  const _ChartCard({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 10,
            barTouchData: _buildBarTouchData(),
            titlesData: _buildTitlesData(context),
            gridData: _buildGridData(),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(
              values.length,
              (index) => _buildBarChartGroupData(index, values[index]),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.shade200,
          strokeWidth: 1,
        );
      },
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipColor: (group) => AppTheme.primaryText.withAlpha(220),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${labels[group.x.toInt()]}\n',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            children: <TextSpan>[
              TextSpan(
                text: rod.toY.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
      touchCallback: (event, response) {
      },
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sideTitleStyle = textTheme.bodySmall?.copyWith(color: AppTheme.primaryText.withAlpha(120));

    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            if (value % 2 != 0) return const SizedBox.shrink();
            return Text(value.toInt().toString(), style: sideTitleStyle, textAlign: TextAlign.left);
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 38,
          getTitlesWidget: (double value, TitleMeta meta) {
            final index = value.toInt();
            final text = Text(labels[index], style: sideTitleStyle);

            return Padding(padding: const EdgeInsets.only(top: 10.0), child: text);
          },
        ),
      ),
    );
  }

  BarChartGroupData _buildBarChartGroupData(int index, double value) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withAlpha(150)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withAlpha(40),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consejo del Día',
                    style: GoogleFonts.interTight(
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recuerda tomarte un momento para respirar profundamente. Un pequeño descanso puede hacer una gran diferencia.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryText.withAlpha(180),
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }
}