import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme.dart';
import '../bloc/specialistdashboard_bloc.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                  AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryColor.withAlpha((0.2 * 255).round()),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Resumen del día',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.titleLarge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      icon: Icons.calendar_today,
                      label: 'Total citas',
                      value: state.todayAppointmentsCount.toString(),
                      color: AppTheme.primaryColor,
                    ),
                    _SummaryItem(
                      icon: Icons.pending_actions,
                      label: 'Pendientes',
                      value: state.pendingAppointmentsCount.toString(),
                      color: Colors.orange,
                    ),
                    _SummaryItem(
                      icon: Icons.check_circle_outline,
                      label: 'Completadas',
                      value: state.completedAppointmentsCount.toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.interTight(
            textStyle: textTheme.headlineSmall,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
          ),
        ),
      ],
    );
  }
}