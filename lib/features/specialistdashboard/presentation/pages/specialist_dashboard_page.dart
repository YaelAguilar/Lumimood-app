import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../bloc/specialistdashboard_bloc.dart';
import '../widgets/appointment_card.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/professional_id_card.dart';
import '../widgets/patient_card.dart';

class SpecialistDashboardPage extends StatelessWidget {
  const SpecialistDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SpecialistDashboardBloc>()..add(LoadDashboardData()),
      child: const _SpecialistDashboardView(),
    );
  }
}

class _SpecialistDashboardView extends StatefulWidget {
  const _SpecialistDashboardView();

  @override
  State<_SpecialistDashboardView> createState() => _SpecialistDashboardViewState();
}

class _SpecialistDashboardViewState extends State<_SpecialistDashboardView> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpecialistDashboardBloc, SpecialistDashboardState>(
      listener: (context, state) {
        if (state.status == DashboardStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          drawer: const _DashboardDrawer(),
          body: Stack(
            children: [
              const AnimatedBackground(),
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    elevation: 0,
                    backgroundColor: AppTheme.scaffoldBackground.withAlpha((0.8 * 255).round()),
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
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
                      'Dashboard',
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: AppTheme.primaryText),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          // TODO: Implementar notificaciones
                        },
                        tooltip: 'Notificaciones',
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        const _WelcomeCard(),
                        const SizedBox(height: 24),
                        _buildTabBar(),
                        const SizedBox(height: 24),
                        _buildTabContent(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implementar agregar nueva cita
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _TabButton(
                label: isSmallScreen ? 'Inicio' : 'Resumen',
                icon: Icons.dashboard_outlined,
                isSelected: _selectedTabIndex == 0,
                onTap: () => setState(() => _selectedTabIndex = 0),
                isCompact: isSmallScreen,
              ),
            ),
            Expanded(
              flex: 1,
              child: _TabButton(
                label: isSmallScreen ? 'Pacientes' : 'Pacientes',
                icon: Icons.people_outline,
                isSelected: _selectedTabIndex == 1,
                onTap: () {
                  setState(() => _selectedTabIndex = 1);
                  // Cargar TODOS los pacientes cuando se selecciona la pestaña
                  context.read<SpecialistDashboardBloc>().add(LoadAllPatients());
                },
                isCompact: isSmallScreen,
              ),
            ),
            Expanded(
              flex: 1,
              child: _TabButton(
                label: isSmallScreen ? 'ID' : 'Mi ID',
                icon: Icons.badge_outlined,
                isSelected: _selectedTabIndex == 2,
                onTap: () => setState(() => _selectedTabIndex = 2),
                isCompact: isSmallScreen,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          children: [
            const DashboardSummaryCard(),
            const SizedBox(height: 24),
            const _AppointmentsSection(),
          ],
        );
      case 1:
        return const _PatientsSection();
      case 2:
        return const _ProfessionalIdSection();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: 12, 
          horizontal: isCompact ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: isCompact ? 18 : 20,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontSize: isCompact ? 10 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final timeOfDay = now.hour < 12
        ? 'Buenos días'
        : now.hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    final greeting = now.hour < 12
        ? '🌅'
        : now.hour < 18
            ? '☀️'
            : '🌙';

    return BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
      builder: (context, state) {
        final professionalName = state.professionalName ?? 'Doctor';
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withAlpha((0.95 * 255).round()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeOfDay,
                      style: GoogleFonts.interTight(
                        textStyle: textTheme.titleMedium,
                        color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dr. $professionalName',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.headlineMedium,
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aquí está tu agenda para hoy',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.bodyMedium,
                    color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        );
      },
    );
  }
}

class _AppointmentsSection extends StatelessWidget {
  const _AppointmentsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
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
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                        AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Citas del día',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
                        builder: (context, state) {
                          final formattedDate = DateFormat.yMMMMd('es_ES').format(state.selectedDate);
                          return Text(
                            formattedDate,
                            style: GoogleFonts.interTight(
                              textStyle: textTheme.bodySmall,
                              color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<SpecialistDashboardBloc>().add(RefreshDashboard());
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
              builder: (context, state) {
                if (state.status == DashboardStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (state.status == DashboardStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'Error al cargar las citas',
                            style: TextStyle(color: Colors.red[300]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SpecialistDashboardBloc>().add(LoadDashboardData());
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.appointments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay citas programadas para hoy',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar una nueva cita',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.appointments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appointment = state.appointments[index];
                    return AppointmentCard(appointment: appointment)
                        .animate(delay: (index * 100).ms)
                        .fadeIn()
                        .slideY(begin: 0.2, curve: Curves.easeOutBack);
                  },
                );
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
    );
  }
}

class _PatientsSection extends StatelessWidget {
  const _PatientsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
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
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                        AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.people, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Todos los Pacientes',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
                        builder: (context, state) {
                          return Text(
                            '${state.totalPatientsCount} pacientes registrados en el sistema',
                            style: GoogleFonts.interTight(
                              textStyle: textTheme.bodySmall,
                              color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<SpecialistDashboardBloc>().add(LoadAllPatients());
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
              builder: (context, state) {
                if (state.patientsStatus == PatientsStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (state.patientsStatus == PatientsStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar los pacientes',
                            style: TextStyle(color: Colors.red[300]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SpecialistDashboardBloc>().add(LoadAllPatients());
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.patients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay pacientes registrados en el sistema',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los pacientes aparecerán aquí cuando se registren',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.patients.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final patient = state.patients[index];
                    return PatientCard(patient: patient)
                        .animate(delay: (index * 100).ms)
                        .fadeIn()
                        .slideY(begin: 0.2, curve: Curves.easeOutBack);
                  },
                );
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
    );
  }
}

class _ProfessionalIdSection extends StatelessWidget {
  const _ProfessionalIdSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecialistDashboardBloc, SpecialistDashboardState>(
      builder: (context, state) {
        if (state.professionalId == null || state.professionalName == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ProfessionalIdCard(
            professionalId: state.professionalId!,
            professionalName: state.professionalName!,
          ),
        );
      },
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  const _DashboardDrawer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFFBBDEFB),
                  Color(0xFF90CAF9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'specialist_avatar',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.medical_services,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Panel del Especialista',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.titleLarge,
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestiona tus citas y pacientes',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.bodyMedium,
                    color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  isSelected: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _DrawerItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Calendario',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar a calendario
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  title: 'Pacientes',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar a lista de pacientes
                  },
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  title: 'Reportes',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar a reportes
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navegar a configuración
                  },
                ),
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

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withAlpha((0.1 * 255).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}