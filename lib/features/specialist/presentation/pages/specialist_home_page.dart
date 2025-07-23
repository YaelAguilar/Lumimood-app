import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../core/presentation/theme.dart';
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
      backgroundColor: AppTheme.scaffoldBackground,
      body: BlocBuilder<SpecialistBloc, SpecialistState>(
        builder: (context, state) {
          log('--- [BUILDER] Building UI for state: ${state.status} ---');

          switch (state.status) {
            case SpecialistStatus.initial:
            case SpecialistStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            
            case SpecialistStatus.error:
              return Center(
                child: Text(state.errorMessage ?? 'Ocurrió un error'),
              );

            case SpecialistStatus.loaded:
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(20.0),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300)
                  ),
                  child: Text(
                    '¡Panel Cargado!\n\nSe recibieron ${state.appointments.length} citas de prueba.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}