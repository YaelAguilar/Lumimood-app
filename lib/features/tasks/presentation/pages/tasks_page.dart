import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Aquí se mostrará la lista de tareas pendientes.'),
      ),
    );
  }
}