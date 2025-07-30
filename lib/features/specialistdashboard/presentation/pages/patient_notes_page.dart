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
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/bloc/notes_bloc.dart';
import '../../../patients/domain/entities/patient_entity.dart';

class PatientNotesPage extends StatelessWidget {
  final PatientEntity patient;
  
  const PatientNotesPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotesBloc>()..add(LoadNotes()),
      child: _PatientNotesView(patient: patient),
    );
  }
}

class _PatientNotesView extends StatelessWidget {
  final PatientEntity patient;
  
  const _PatientNotesView({required this.patient});

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
                title: Column(
                  children: [
                    Text(
                      'Notas del Paciente',
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
                child: BlocConsumer<NotesBloc, NotesState>(
                  listener: (context, state) {
                    if (state.status == NotesStatus.error) {
                      log('❌ PATIENT NOTES: Error loading notes - ${state.errorMessage}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage ?? 'Error al cargar las notas'),
                          backgroundColor: Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    log('📝 PATIENT NOTES: Current state - ${state.status}, Notes count: ${state.notes.length}');
                    
                    if (state.status == NotesStatus.loading || state.status == NotesStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Cargando notas del paciente...'),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (state.status == NotesStatus.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar las notas',
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
                                  context.read<NotesBloc>().add(LoadNotes());
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Filtrar notas del paciente específico
                    final patientNotes = state.notes.where(
                      (note) => note.patientId == patient.id
                    ).toList();
                    
                    if (patientNotes.isEmpty) {
                      return _EmptyNotesView(patient: patient);
                    }
                    
                    return _PatientNotesList(notes: patientNotes, patient: patient);
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

class _EmptyNotesView extends StatelessWidget {
  final PatientEntity patient;
  
  const _EmptyNotesView({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 150, left: 32, right: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 80, color: AppTheme.primaryColor.withAlpha(120)),
            const SizedBox(height: 24),
            Text(
              '${patient.name} aún no tiene notas',
              style: GoogleFonts.interTight(
                textStyle: Theme.of(context).textTheme.headlineSmall,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Las notas que ${patient.name} escriba aparecerán aquí.',
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

class _PatientNotesList extends StatelessWidget {
  final List<Note> notes;
  final PatientEntity patient;
  
  const _PatientNotesList({required this.notes, required this.patient});

  @override
  Widget build(BuildContext context) {
    log('📝 PATIENT NOTES LIST: Building list with ${notes.length} notes');
    
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
                  Icons.note_alt,
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
                      '${notes.length} nota${notes.length == 1 ? '' : 's'}',
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Registradas por ${patient.name}',
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
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _PatientNoteCard(note: note, patient: patient)
                .animate()
                .fadeIn(delay: (100 + index * 50).ms)
                .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _PatientNoteCard extends StatelessWidget {
  final Note note;
  final PatientEntity patient;
  
  const _PatientNoteCard({required this.note, required this.patient});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat.yMMMMd('es_ES').format(note.date);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withAlpha(220),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showNoteDetail(context, note, patient);
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.inter(
                        textStyle: textTheme.titleLarge,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryText.withAlpha(160),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showNoteDetail(context, note, patient);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Leer completa'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteDetail(BuildContext context, Note note, PatientEntity patient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle para cerrar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.note_alt,
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
                          note.title,
                          style: GoogleFonts.interTight(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Por ${patient.name} • ${DateFormat.yMMMMd('es_ES').format(note.date)}',
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
            
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppTheme.primaryText.withAlpha(200),
                    ),
                  ),
                ),
              ),
            ),
            
            // Botón de cerrar
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}