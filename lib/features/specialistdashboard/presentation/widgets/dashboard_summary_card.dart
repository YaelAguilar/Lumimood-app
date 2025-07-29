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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    
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
                // Cambiamos a un layout adaptativo basado en el tamaño de pantalla
                isSmallScreen 
                  ? _buildCompactLayout(state)
                  : _buildNormalLayout(state),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildNormalLayout(SpecialistDashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: _SummaryItem(
            icon: Icons.calendar_today,
            label: 'Total citas',
            value: state.todayAppointmentsCount.toString(),
            color: AppTheme.primaryColor,
            isCompact: false,
          ),
        ),
        Flexible(
          child: _SummaryItem(
            icon: Icons.pending_actions,
            label: 'Pendientes',
            value: state.pendingAppointmentsCount.toString(),
            color: Colors.orange,
            isCompact: false,
          ),
        ),
        Flexible(
          child: _SummaryItem(
            icon: Icons.people,
            label: 'Pacientes',
            value: state.totalPatientsCount.toString(),
            color: Colors.blue,
            isCompact: false,
          ),
        ),
        Flexible(
          child: _SummaryItem(
            icon: Icons.check_circle_outline,
            label: 'Completadas',
            value: state.completedAppointmentsCount.toString(),
            color: Colors.green,
            isCompact: false,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(SpecialistDashboardState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.calendar_today,
                label: 'Total citas',
                value: state.todayAppointmentsCount.toString(),
                color: AppTheme.primaryColor,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryItem(
                icon: Icons.pending_actions,
                label: 'Pendientes',
                value: state.pendingAppointmentsCount.toString(),
                color: Colors.orange,
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.people,
                label: 'Pacientes',
                value: state.totalPatientsCount.toString(),
                color: Colors.blue,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryItem(
                icon: Icons.check_circle_outline,
                label: 'Completadas',
                value: state.completedAppointmentsCount.toString(),
                color: Colors.green,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isCompact;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.7 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.interTight(
                      textStyle: textTheme.titleMedium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Layout normal para pantallas grandes
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.interTight(
            textStyle: textTheme.titleLarge,
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
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}