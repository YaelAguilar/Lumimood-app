import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
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

  void _showAddTaskDialog(BuildContext context) {
    final taskController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Añadir Nueva Tarea', style: Theme.of(dialogContext).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextField(
                controller: taskController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Título de la tarea'),
                onSubmitted: (_) {
                  if (taskController.text.isNotEmpty) {
                    context.read<TasksBloc>().add(AddNewTask(taskController.text));
                  }
                  Navigator.pop(dialogContext);
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    context.read<TasksBloc>().add(AddNewTask(taskController.text));
                  }
                  Navigator.pop(dialogContext);
                },
                text: 'Añadir',
                options: ButtonOptions(
                  width: double.infinity,
                  height: 50,
                  color: AppTheme.primaryColor,
                  textStyle: Theme.of(dialogContext).textTheme.titleSmall!.copyWith(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Tareas', style: GoogleFonts.interTight(textStyle: textTheme.headlineSmall)),
        centerTitle: false,
      ),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state.status == TasksStatus.loading || state.status == TasksStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == TasksStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Error al cargar tareas'));
          }

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearPercentIndicator(
                    percent: state.progress,
                    lineHeight: 12.0,
                    backgroundColor: AppTheme.alternate,
                    progressColor: AppTheme.primaryColor,
                    barRadius: const Radius.circular(0),
                    padding: EdgeInsets.zero,
                    animation: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Text(
                      state.tasks.isEmpty ? 'Añade tu primera tarea' : 'Tus tareas',
                      style: textTheme.labelMedium
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.alternate, width: 1),
                            ),
                            child: CheckboxListTile(
                              value: task.isCompleted,
                              onChanged: (_) => context.read<TasksBloc>().add(ToggleTask(task.id)),
                              title: Text(
                                task.title, 
                                style: textTheme.bodyLarge?.copyWith(
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                  color: task.isCompleted ? Colors.grey : null
                                )
                              ),
                              activeColor: AppTheme.primaryColor,
                              checkColor: Colors.white,
                              controlAffinity: ListTileControlAffinity.trailing,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.transparent,
                  height: 140,
                  width: double.infinity,
                  child: Center(
                    child: CustomButton(
                      onPressed: () => _showAddTaskDialog(context),
                      text: 'Añadir Tarea',
                      icon: const Icon(Icons.add, color: Colors.white),
                      options: ButtonOptions(
                        width: 270,
                        height: 50,
                        color: AppTheme.primaryColor,
                        textStyle: GoogleFonts.interTight(
                          textStyle: textTheme.titleSmall,
                          color: Colors.white,
                        ),
                        elevation: 4,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}