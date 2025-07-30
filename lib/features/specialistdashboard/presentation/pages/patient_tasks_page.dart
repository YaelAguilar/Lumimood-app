import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:developer';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/bloc/tasks_bloc.dart';
import '../../../patients/domain/entities/patient_entity.dart';

class PatientTasksPage extends StatelessWidget {
  final PatientEntity patient;
  
  const PatientTasksPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TasksBloc>()..add(LoadTasks()),
      child: _PatientTasksView(patient: patient),
    );
  }
}

class _PatientTasksView extends StatelessWidget {
  final PatientEntity patient;
  
  const _PatientTasksView({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: _AddTaskFAB(patient: patient),
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
                      'Tareas del Paciente',
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
                child: BlocConsumer<TasksBloc, TasksState>(
                  listener: (context, state) {
                    if (state.status == TasksStatus.error) {
                      log('❌ PATIENT TASKS: Error loading tasks - ${state.errorMessage}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage ?? 'Error al cargar las tareas'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    log('📋 PATIENT TASKS: Current state - ${state.status}, Tasks count: ${state.tasks.length}');
                    
                    if (state.status == TasksStatus.loading || state.status == TasksStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Cargando tareas del paciente...'),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (state.status == TasksStatus.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar las tareas',
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
                                  context.read<TasksBloc>().add(LoadTasks());
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Por ahora, mostramos todas las tareas ya que son estáticas
                    // En el futuro, cuando las tareas estén en BD, filtraremos por paciente
                    final patientTasks = state.tasks;
                    
                    if (patientTasks.isEmpty) {
                      return _EmptyTasksView(patient: patient);
                    }
                    
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        _TasksProgressCard(
                          progress: state.progress, 
                          taskCount: patientTasks.length,
                          patient: patient,
                        ),
                        const SizedBox(height: 16),
                        _PatientTasksList(tasks: patientTasks, patient: patient),
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

class _EmptyTasksView extends StatelessWidget {
  final PatientEntity patient;
  
  const _EmptyTasksView({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 150, left: 32, right: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_outlined, size: 80, color: AppTheme.primaryColor.withAlpha(120)),
            const SizedBox(height: 24),
            Text(
              '${patient.name} no tiene tareas asignadas',
              style: GoogleFonts.interTight(
                textStyle: Theme.of(context).textTheme.headlineSmall,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Puedes asignar nuevas tareas usando el botón de abajo.',
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

class _TasksProgressCard extends StatelessWidget {
  final double progress;
  final int taskCount;
  final PatientEntity patient;

  const _TasksProgressCard({
    required this.progress, 
    required this.taskCount,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completedTasks = (progress * taskCount).round();

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
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
                        'Progreso de ${patient.name}',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tareas completadas: $completedTasks de $taskCount',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryText.withAlpha(150)
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.inter(
                    textStyle: textTheme.headlineMedium,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearPercentIndicator(
              percent: progress,
              lineHeight: 14.0,
              backgroundColor: AppTheme.alternate,
              progressColor: AppTheme.primaryColor,
              barRadius: const Radius.circular(12),
              padding: EdgeInsets.zero,
              animation: true,
              animateFromLastPercent: true,
              animationDuration: 800,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: progress >= 0.8 
                  ? Colors.green.shade50 
                  : progress >= 0.5 
                    ? Colors.orange.shade50 
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: progress >= 0.8 
                    ? Colors.green.shade200 
                    : progress >= 0.5 
                      ? Colors.orange.shade200 
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    progress >= 0.8 
                      ? Icons.celebration 
                      : progress >= 0.5 
                        ? Icons.schedule 
                        : Icons.info_outline,
                    color: progress >= 0.8 
                      ? Colors.green.shade600 
                      : progress >= 0.5 
                        ? Colors.orange.shade600 
                        : Colors.blue.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      progress >= 0.8 
                        ? '¡Excelente progreso! ${patient.name} está muy bien.'
                        : progress >= 0.5 
                          ? '${patient.name} va por buen camino.'
                          : '${patient.name} está comenzando su proceso.',
                      style: TextStyle(
                        color: progress >= 0.8 
                          ? Colors.green.shade700 
                          : progress >= 0.5 
                            ? Colors.orange.shade700 
                            : Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}

class _PatientTasksList extends StatelessWidget {
  final List<Task> tasks;
  final PatientEntity patient;

  const _PatientTasksList({required this.tasks, required this.patient});

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
                  Icons.task_alt,
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
                      '${tasks.length} tarea${tasks.length == 1 ? '' : 's'}',
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Asignadas a ${patient.name}',
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _PatientTaskItem(task: task, patient: patient)
                .animate()
                .fadeIn(delay: (200 + index * 100).ms)
                .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutCubic);
          },
        ),
      ],
    );
  }
}

class _PatientTaskItem extends StatelessWidget {
  final Task task;
  final PatientEntity patient;

  const _PatientTaskItem({required this.task, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<TasksBloc>().add(ToggleTask(task.id));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: task.isCompleted
                      ? const LinearGradient(
                          colors: [AppTheme.primaryColor, Color(0xFF81C784)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: Border.all(
                    color: task.isCompleted ? Colors.transparent : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            color: task.isCompleted ? Colors.grey.shade500 : AppTheme.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                      child: Text(task.title),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          task.isCompleted ? Icons.check_circle : Icons.schedule,
                          size: 14,
                          color: task.isCompleted 
                            ? Colors.green.shade600 
                            : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.isCompleted ? 'Completada' : 'Pendiente',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: task.isCompleted 
                              ? Colors.green.shade600 
                              : Colors.orange.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (task.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTaskFAB extends StatelessWidget {
  final PatientEntity patient;
  
  const _AddTaskFAB({required this.patient});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        _showAddTaskDialog(context);
      },
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Asignar Tarea',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut);
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Asignar nueva tarea',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarea para: ${patient.fullName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryText.withAlpha(150),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: taskController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe la tarea que quieres asignar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.trim().isNotEmpty) {
                // En el contexto real, aquí se enviaría la tarea al servidor
                // Por ahora, solo agregamos a la lista local
                context.read<TasksBloc>().add(AddNewTask(taskController.text.trim()));
                Navigator.of(dialogContext).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tarea asignada a ${patient.name}'),
                    backgroundColor: AppTheme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Asignar'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  }