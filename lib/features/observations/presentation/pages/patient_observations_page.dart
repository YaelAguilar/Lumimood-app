// ARCHIVO: lib/features/observations/presentation/pages/patient_observations_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/observation.dart';
import '../bloc/observations_bloc.dart';
import '../../../patients/domain/entities/patient_entity.dart';

class PatientObservationsPage extends StatelessWidget {
  final PatientEntity patient;
  
  const PatientObservationsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    log('🔍 DEBUG: Building PatientObservationsPage for patient: ${patient.id}');
    return BlocProvider(
      create: (context) {
        log('🔍 DEBUG: Creating ObservationsBloc');
        return getIt<ObservationsBloc>()..add(LoadObservations(patientId: patient.id));
      },
      child: _PatientObservationsView(patient: patient),
    );
  }
}

class _PatientObservationsView extends StatelessWidget {
  final PatientEntity patient;
  
  const _PatientObservationsView({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: _AddObservationFAB(patient: patient),
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
                title: Column(
                  children: [
                    Text(
                      'Observaciones',
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      patient.fullName,
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        color: AppTheme.primaryText.withAlpha(150),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                expandedHeight: 120,
              ),
              SliverToBoxAdapter(
                child: BlocConsumer<ObservationsBloc, ObservationsState>(
                  listener: (context, state) {
                    if (state.status == ObservationsStatus.error) {
                      log('❌ PATIENT OBSERVATIONS: Error loading observations - ${state.errorMessage}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage ?? 'Error al cargar las observaciones'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    
                    if (state.creationStatus == ObservationCreationStatus.success) {
                      log('✅ PATIENT OBSERVATIONS: Observation created successfully');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Observación agregada exitosamente'),
                          backgroundColor: AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    
                    if (state.creationStatus == ObservationCreationStatus.error) {
                      log('❌ PATIENT OBSERVATIONS: Error creating observation - ${state.errorMessage}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage ?? 'Error al agregar la observación'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    log('📋 PATIENT OBSERVATIONS: Current state - ${state.status}, Total observations: ${state.observations.length}, Filtered: ${state.filteredObservations.length}');
                    
                    if (state.status == ObservationsStatus.loading || state.status == ObservationsStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Cargando observaciones del paciente...'),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (state.status == ObservationsStatus.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar las observaciones',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.errorMessage ?? 'Error desconocido',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ObservationsBloc>().add(LoadObservations(patientId: patient.id));
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Filtrar observaciones por patientId
                    final patientObservations = state.observations.where(
                      (observation) => observation.patientId == patient.id
                    ).toList();
                    
                    log('📋 PATIENT OBSERVATIONS: Found ${patientObservations.length} observations for patient ${patient.id}');
                    
                    if (patientObservations.isEmpty) {
                      return _EmptyObservationsView(patient: patient);
                    }
                    
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        const _FilterChips(),
                        const SizedBox(height: 16),
                        _PatientObservationsList(observations: patientObservations, patient: patient),
                        const SizedBox(height: 80), // Espacio para el FAB
                      ],
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

class _EmptyObservationsView extends StatelessWidget {
  final PatientEntity patient;
  
  const _EmptyObservationsView({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 150, left: 32, right: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 80, color: AppTheme.primaryColor.withAlpha(120)),
            const SizedBox(height: 24),
            Text(
              '${patient.name} no tiene observaciones',
              style: GoogleFonts.interTight(
                textStyle: Theme.of(context).textTheme.headlineSmall,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Puedes agregar observaciones usando el botón de abajo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryText.withAlpha(150),
                  ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ObservationsBloc, ObservationsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todas',
                  isSelected: state.selectedType == null && state.selectedPriority == null,
                  onSelected: () {
                    context.read<ObservationsBloc>().add(FilterObservations());
                  },
                ),
                const SizedBox(width: 8),
                ...ObservationType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: type.displayName,
                      isSelected: state.selectedType == type,
                      onSelected: () {
                        context.read<ObservationsBloc>().add(FilterObservations(type: type));
                      },
                    ),
                  );
                }),
                const SizedBox(width: 16),
                ...ObservationPriority.values.map((priority) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: 'Prioridad ${priority.displayName}',
                      isSelected: state.selectedPriority == priority,
                      onSelected: () {
                        context.read<ObservationsBloc>().add(FilterObservations(priority: priority));
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }
}

class _PatientObservationsList extends StatelessWidget {
  final List<Observation> observations;
  final PatientEntity patient;

  const _PatientObservationsList({required this.observations, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.note_outlined,
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
                      '${observations.length} observación${observations.length == 1 ? '' : 'es'}',
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Realizadas a ${patient.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryText.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: observations.length,
          itemBuilder: (context, index) {
            final observation = observations[index];
            return _PatientObservationCard(observation: observation, patient: patient)
                .animate()
                .fadeIn(delay: (100 + index * 50).ms)
                .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
          },
        ),
      ],
    );
  }
}

class _PatientObservationCard extends StatelessWidget {
  final Observation observation;
  final PatientEntity patient;
  
  const _PatientObservationCard({required this.observation, required this.patient});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat.yMMMMd('es_ES').add_Hms().format(observation.date);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withAlpha(220),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: observation.type.color.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    observation.type.icon,
                    color: observation.type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            observation.type.displayName,
                            style: GoogleFonts.inter(
                              textStyle: textTheme.titleMedium,
                              fontWeight: FontWeight.w600,
                              color: observation.type.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: observation.priority.color.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              observation.priority.displayName,
                              style: TextStyle(
                                color: observation.priority.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por ${observation.professionalName}',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryText.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              observation.content,
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryText.withAlpha(180),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    textStyle: textTheme.bodySmall,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddObservationFAB extends StatelessWidget {
  final PatientEntity patient;
  
  const _AddObservationFAB({required this.patient});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        log('🔍 DEBUG: FAB pressed for patient: ${patient.id}');
        HapticFeedback.lightImpact();
        _showAddObservationDialog(context);
      },
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Agregar Observación',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut);
  }

  void _showAddObservationDialog(BuildContext context) {
    log('🔍 DEBUG: Showing add observation dialog');
    
    final TextEditingController contentController = TextEditingController();
    ObservationType selectedType = ObservationType.general;
    ObservationPriority selectedPriority = ObservationPriority.normal;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Nueva Observación',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Observación para: ${patient.fullName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryText.withAlpha(150),
                ),
              ),
              const SizedBox(height: 16),
              
              // Selector de tipo
              Text(
                'Tipo de observación:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ObservationType>(
                value: selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ObservationType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 16, color: type.color),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                    log('🔍 DEBUG: Selected type changed to: ${value.displayName}');
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Selector de prioridad
              Text(
                'Prioridad:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ObservationPriority>(
                value: selectedPriority,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ObservationPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(
                      priority.displayName,
                      style: TextStyle(color: priority.color),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPriority = value;
                    });
                    log('🔍 DEBUG: Selected priority changed to: ${value.displayName}');
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Campo de contenido
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe la observación...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                autofocus: true,
                onChanged: (value) {
                  log('🔍 DEBUG: Content changed, length: ${value.length}');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                log('🔍 DEBUG: Cancel button pressed');
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            BlocBuilder<ObservationsBloc, ObservationsState>(
              builder: (context, state) {
                final isLoading = state.creationStatus == ObservationCreationStatus.loading;
                
                return ElevatedButton(
                  onPressed: isLoading ? null : () {
                    log('🔍 DEBUG: Add button pressed');
                    log('🔍 DEBUG: Content length: ${contentController.text.trim().length}');
                    
                    if (contentController.text.trim().isNotEmpty) {
                      log('🔍 DEBUG: Content is not empty');
                      log('🔍 DEBUG: Patient ID: ${patient.id}');
                      log('🔍 DEBUG: Selected type: ${selectedType.displayName}');
                      log('🔍 DEBUG: Selected priority: ${selectedPriority.displayName}');
                      log('🔍 DEBUG: Content: "${contentController.text.trim()}"');
                      
                      try {
                        log('🔍 DEBUG: About to add AddNewObservation event');
                        
                        // Verificar que el context y el bloc estén disponibles
                        final bloc = context.read<ObservationsBloc>();
                        log('🔍 DEBUG: Got bloc: ${bloc.runtimeType}');
                        
                        final event = AddNewObservation(
                          patientId: patient.id,
                          content: contentController.text.trim(),
                          type: selectedType,
                          priority: selectedPriority,
                        );
                        log('🔍 DEBUG: Created event: $event');
                        
                        bloc.add(event);
                        log('🔍 DEBUG: Event added successfully to bloc');
                        
                        Navigator.of(dialogContext).pop();
                        log('🔍 DEBUG: Dialog closed');
                        
                      } catch (e, stackTrace) {
                        log('❌ DEBUG: Error adding event: $e');
                        log('❌ DEBUG: Stack trace: $stackTrace');
                        
                        // Mostrar error al usuario
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      log('🔍 DEBUG: Content is empty, showing snackbar');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, escribe el contenido de la observación'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Agregar'),
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}