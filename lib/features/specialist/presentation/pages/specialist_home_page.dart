import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/specialist_bloc.dart';

class SpecialistHomePage extends StatelessWidget {
  const SpecialistHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SpecialistHomeView();
  }
}

class _SpecialistHomeView extends StatelessWidget {
  const _SpecialistHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      drawer: const _SpecialistDrawer(),
      body: Stack(
        children: [
          const AnimatedBackground(),
          BlocConsumer<SpecialistBloc, SpecialistState>(
            listener: (context, state) {
              log('Listener in SpecialistHomePage received new state: ${state.status}');
              if (state.status == SpecialistStatus.error) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'Ocurrió un error'),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            builder: (context, state) {
              log('Builder in SpecialistHomePage building for state: ${state.status}');
              switch (state.status) {
                case SpecialistStatus.initial:
                case SpecialistStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                
                case SpecialistStatus.error:
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'Ocurrió un error al cargar los datos.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );

                case SpecialistStatus.loaded:
                  return CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(context),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _WelcomeCard(appointmentCount: state.appointments.length),
                            const SizedBox(height: 24),
                            const _QuickActionsSection(),
                            const SizedBox(height: 24),
                            const _PatientsOverviewCard(),
                            const SizedBox(height: 24),
                            _ScheduleCard(appointments: state.appointments),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      
      // --- OPTIMIZACIÓN APLICADA ---
      // Se reemplaza el costoso BackdropFilter por un color de fondo
      // semi-transparente. Esto es miles de veces más rápido de renderizar
      // y soluciona el problema de la carga lenta.
      backgroundColor: AppTheme.scaffoldBackground.withAlpha(230), // 230 es ~90% opacidad
      
      // La propiedad `flexibleSpace` con el BackdropFilter ha sido eliminada.
      
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: AppTheme.primaryText, size: 28),
          onPressed: () {
            HapticFeedback.lightImpact();
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Text(
        'Panel Especialista',
        style: GoogleFonts.interTight(
          textStyle: Theme.of(context).textTheme.headlineSmall,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppTheme.primaryText),
          onPressed: () {},
          tooltip: 'Notificaciones',
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final int appointmentCount;
  const _WelcomeCard({required this.appointmentCount});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sessionState = context.watch<SessionCubit>().state;
    String specialistName = 'Dr. Especialista';
    if (sessionState is AuthenticatedSessionState) {
      specialistName = sessionState.user.name;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido de nuevo,', style: textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        specialistName,
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.headlineSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tienes $appointmentCount citas programadas para hoy',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: GoogleFonts.interTight(
              textStyle: Theme.of(context).textTheme.titleLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _QuickActionCard(icon: Icons.person_add_outlined, title: 'Nuevo Paciente', color: Colors.blue.shade600, onTap: () {})),
              const SizedBox(width: 12),
              Expanded(child: _QuickActionCard(icon: Icons.event_note_outlined, title: 'Agendar Cita', color: Colors.green.shade600, onTap: () {})),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).round()), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PatientsOverviewCard extends StatelessWidget {
  const _PatientsOverviewCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Resumen de Pacientes', style: GoogleFonts.interTight(textStyle: textTheme.titleLarge, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Ver todos')),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: _StatCard(title: 'Total Pacientes', value: '127', icon: Icons.people_outline, color: Colors.blue)),
                SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'Nuevos este mes', value: '12', icon: Icons.person_add_alt_outlined, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withAlpha((0.05 * 255).round()), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryText.withAlpha((0.7 * 255).round()))),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  const _ScheduleCard({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Próximas Citas', style: GoogleFonts.interTight(textStyle: textTheme.titleLarge, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (appointments.isEmpty)
              const Center(child: Text('No hay citas programadas para hoy.'))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return _AppointmentItem(appointment: appointment, color: Colors.blue);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
  }
}

class _AppointmentItem extends StatelessWidget {
  final AppointmentEntity appointment;
  final Color color;

  const _AppointmentItem({required this.appointment, required this.color});

  @override
  Widget build(BuildContext context) {
    final String patientName = 'Paciente #${appointment.patientId.substring(0, 4)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.scaffoldBackground, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(width: 4, height: 50, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(appointment.time, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(patientName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(appointment.reason, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryText.withAlpha((0.6 * 255).round()))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {},
            color: AppTheme.primaryText.withAlpha((0.5 * 255).round()),
          ),
        ],
      ),
    );
  }
}

class _SpecialistDrawer extends StatelessWidget {
  const _SpecialistDrawer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24))),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1976D2), Color(0xFF1565C0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Center(child: Icon(Icons.medical_services, size: 40, color: Colors.blue[700])),
                ),
                const SizedBox(height: 16),
                Text('Dr. Especialista', style: GoogleFonts.interTight(textStyle: textTheme.titleLarge, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DrawerItem(icon: Icons.dashboard_outlined, title: 'Panel Principal', isSelected: true, onTap: () => Navigator.of(context).pop()),
                _DrawerItem(icon: Icons.people_outline, title: 'Pacientes', onTap: () { Navigator.of(context).pop(); }),
                _DrawerItem(icon: Icons.calendar_month_outlined, title: 'Agenda', onTap: () { Navigator.of(context).pop(); }),
                const Divider(height: 32),
                _DrawerItem(icon: Icons.settings_outlined, title: 'Configuración', onTap: () { Navigator.of(context).pop(); }),
                _DrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Cerrar sesión',
                  onTap: () {
                    context.read<SessionCubit>().signOut();
                    context.goNamed('welcome');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.title, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withAlpha((0.1 * 255).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue[700] : Colors.grey[600], size: 24),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(color: isSelected ? Colors.blue[700] : Colors.grey[800], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}