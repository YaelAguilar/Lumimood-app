import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/task.dart';
import '../bloc/tasks_bloc.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TasksBloc>()..add(LoadTasks()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

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
                  'Mis Tareas',
                  style: GoogleFonts.interTight(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<TasksBloc, TasksState>(
                  builder: (context, state) {
                    if (state.status == TasksStatus.loading || state.status == TasksStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state.status == TasksStatus.error) {
                      return Center(child: Text(state.errorMessage ?? 'Error al cargar tareas'));
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        _ProgressCard(progress: state.progress, taskCount: state.tasks.length),
                        const SizedBox(height: 16),
                        _TaskList(tasks: state.tasks),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final int taskCount;

  const _ProgressCard({required this.progress, required this.taskCount});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tu Progreso',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.titleLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completedTasks / $taskCount',
                  style: GoogleFonts.inter(
                    textStyle: textTheme.titleMedium,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Sigue así, ¡lo estás haciendo genial!',
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.primaryText.withAlpha(150)),
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
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 60, color: AppTheme.primaryColor.withAlpha(150)),
              const SizedBox(height: 16),
              const Text('¡No hay tareas por hoy!', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskItem(task: task)
            .animate()
            .fadeIn(delay: (200 + index * 100).ms)
            .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;

  const _TaskItem({required this.task});

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
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey.shade500 : AppTheme.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                  child: Text(task.title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}