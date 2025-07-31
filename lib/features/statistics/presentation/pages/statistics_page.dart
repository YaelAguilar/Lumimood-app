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
                  'Análisis Emocional',
                  style: GoogleFonts.interTight(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      const _WeeklyEmotionSummary(),
                      const SizedBox(height: 24),
                      const _WeeklyEmotionChart(),
                      const SizedBox(height: 24),
                      const _EmotionBreakdownCard(),
                      const SizedBox(height: 24),
                      const _EmotionTrendCard(),
                      const SizedBox(height: 24),
                      const _InsightsCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyEmotionSummary extends StatelessWidget {
  const _WeeklyEmotionSummary();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withAlpha(230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_view_week,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen Semanal',
                        style: GoogleFonts.interTight(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Últimos 7 días',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  emoji: '😊',
                  label: 'Emoción\nPredominante',
                  value: 'Calma',
                  color: const Color(0xFF20B2AA),
                ),
                _SummaryItem(
                  emoji: '📊',
                  label: 'Registros\nTotales',
                  value: '42',
                  color: AppTheme.primaryColor,
                ),
                _SummaryItem(
                  emoji: '📈',
                  label: 'Tendencia',
                  value: 'Positiva',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}

class _SummaryItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.interTight(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _WeeklyEmotionChart extends StatelessWidget {
  const _WeeklyEmotionChart();

  // Datos simulados para cada día de la semana
  static final Map<String, List<EmotionData>> weeklyData = {
    'Lun': [
      EmotionData('Felicidad', 3, const Color(0xFFFFD700)),
      EmotionData('Calma', 2, const Color(0xFF20B2AA)),
      EmotionData('Ansiedad', 1, const Color(0xFFFF8C00)),
    ],
    'Mar': [
      EmotionData('Calma', 4, const Color(0xFF20B2AA)),
      EmotionData('Felicidad', 2, const Color(0xFFFFD700)),
      EmotionData('Estrés', 1, const Color.fromARGB(255, 255, 90, 31)),
    ],
    'Mié': [
      EmotionData('Felicidad', 5, const Color(0xFFFFD700)),
      EmotionData('Calma', 3, const Color(0xFF20B2AA)),
    ],
    'Jue': [
      EmotionData('Ansiedad', 2, const Color(0xFFFF8C00)),
      EmotionData('Tristeza', 2, const Color.fromARGB(255, 28, 99, 156)),
      EmotionData('Calma', 1, const Color(0xFF20B2AA)),
    ],
    'Vie': [
      EmotionData('Felicidad', 4, const Color(0xFFFFD700)),
      EmotionData('Calma', 3, const Color(0xFF20B2AA)),
      EmotionData('Enojo', 1, const Color(0xFFDC143C)),
    ],
    'Sáb': [
      EmotionData('Felicidad', 6, const Color(0xFFFFD700)),
      EmotionData('Calma', 2, const Color(0xFF20B2AA)),
    ],
    'Dom': [
      EmotionData('Calma', 5, const Color(0xFF20B2AA)),
      EmotionData('Felicidad', 3, const Color(0xFFFFD700)),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución Emocional Semanal',
              style: GoogleFonts.interTight(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: _buildBarTouchData(),
                  titlesData: _buildTitlesData(context),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  List<BarChartGroupData> _buildBarGroups() {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final emotions = weeklyData[day] ?? [];
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: emotions.fold(0.0, (sum, e) => sum + e.count),
            width: 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            rodStackItems: _buildRodStackItems(emotions),
          ),
        ],
      );
    }).toList();
  }

  List<BarChartRodStackItem> _buildRodStackItems(List<EmotionData> emotions) {
    final items = <BarChartRodStackItem>[];
    double fromY = 0;
    
    for (final emotion in emotions) {
      items.add(
        BarChartRodStackItem(
          fromY,
          fromY + emotion.count,
          emotion.color,
        ),
      );
      fromY += emotion.count;
    }
    
    return items;
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipColor: (group) => AppTheme.primaryText.withAlpha(220),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          final day = days[group.x.toInt()];
          final emotions = weeklyData[day] ?? [];
          
          String tooltipText = '$day\n';
          for (final emotion in emotions) {
            tooltipText += '${emotion.name}: ${emotion.count}\n';
          }
          
          return BarTooltipItem(
            tooltipText.trim(),
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
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
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 38,
          getTitlesWidget: (double value, TitleMeta meta) {
            final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                days[value.toInt()],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmotionBreakdownCard extends StatelessWidget {
  const _EmotionBreakdownCard();

  // Datos simulados de distribución de emociones
  static final List<EmotionPieData> emotionDistribution = [
    EmotionPieData('Felicidad', 35, const Color(0xFFFFD700)),
    EmotionPieData('Calma', 28, const Color(0xFF20B2AA)),
    EmotionPieData('Ansiedad', 15, const Color(0xFFFF8C00)),
    EmotionPieData('Tristeza', 10, const Color.fromARGB(255, 28, 99, 156)),
    EmotionPieData('Estrés', 8, const Color.fromARGB(255, 255, 90, 31)),
    EmotionPieData('Enojo', 4, const Color(0xFFDC143C)),
  ];

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de Emociones',
              style: GoogleFonts.interTight(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Porcentaje de cada emoción registrada',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Gráfico circular
                SizedBox(
                  height: 180,
                  width: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      sections: _buildPieSections(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Aquí puedes manejar el touch si lo deseas
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Leyenda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: emotionDistribution.map((data) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: data.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Text(
                              '${data.percentage}%',
                              style: GoogleFonts.interTight(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  List<PieChartSectionData> _buildPieSections() {
    return emotionDistribution.map((data) {
      final isTouched = false; // Puedes implementar la lógica de touch aquí
      // ignore: dead_code
      final double radius = isTouched ? 95 : 85;
      
      return PieChartSectionData(
        color: data.color,
        value: data.percentage.toDouble(),
        title: '${data.percentage}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _EmotionTrendCard extends StatelessWidget {
  const _EmotionTrendCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withAlpha(40),
              AppTheme.primaryColor.withAlpha(20),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withAlpha(50),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tendencia Positiva',
                        style: GoogleFonts.interTight(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '+15% de emociones positivas',
                        style: TextStyle(
                          color: AppTheme.primaryText.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _TrendItem(
                  icon: Icons.arrow_upward,
                  label: 'Felicidad',
                  value: '+23%',
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _TrendItem(
                  icon: Icons.arrow_downward,
                  label: 'Ansiedad',
                  value: '-12%',
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                _TrendItem(
                  icon: Icons.trending_flat,
                  label: 'Calma',
                  value: 'Estable',
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }
}

class _TrendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TrendItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard();

  final List<String> insights = const [
    'Tu estado emocional ha mejorado un 15% esta semana.',
    'Los martes y jueves muestras más ansiedad. Considera técnicas de relajación esos días.',
    'Tus niveles de felicidad son más altos los fines de semana.',
    'Has registrado emociones consistentemente durante 7 días. ¡Excelente hábito!',
  ];

  @override
  Widget build(BuildContext context) {
    // Seleccionar un insight aleatorio
    final randomInsight = insights[DateTime.now().day % insights.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insight Personal',
                    style: GoogleFonts.interTight(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    randomInsight,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2);
  }
}

// Clases de datos auxiliares
class EmotionData {
  final String name;
  final double count;
  final Color color;

  EmotionData(this.name, this.count, this.color);
}

class EmotionPieData {
  final String name;
  final double percentage;
  final Color color;

  EmotionPieData(this.name, this.percentage, this.color);
}