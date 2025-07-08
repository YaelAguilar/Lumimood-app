import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Aquí se mostrará la lista de todas las notas guardadas.'),
      ),
    );
  }
}