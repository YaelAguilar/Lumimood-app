import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es_ES');
    return BlocProvider(
      create: (context) {
        log('📝 NOTES: Creating NotesBloc and loading notes...');
        return getIt<NotesBloc>()..add(LoadNotes());
      },
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: const _AddNoteFAB(),
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
                  'Mis Notas',
                  style: GoogleFonts.interTight(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: BlocConsumer<NotesBloc, NotesState>(
                  listener: (context, state) {
                    // Listener para errores
                    if (state.status == NotesStatus.error) {
                      log('❌ NOTES: Error loading notes - ${state.errorMessage}');
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
                    log('📝 NOTES: Current state - ${state.status}, Notes count: ${state.notes.length}');
                    
                    // Verificar estado de sesión
                    final sessionState = context.read<SessionCubit>().state;
                    if (sessionState is! AuthenticatedSessionState) {
                      log('❌ NOTES: User not authenticated');
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text('Debes iniciar sesión para ver tus notas'),
                        ),
                      );
                    }

                    if (state.status == NotesStatus.loading || state.status == NotesStatus.initial) {
                      log('🔄 NOTES: Loading state detected');
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Cargando notas...'),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (state.status == NotesStatus.error) {
                      log('❌ NOTES: Error state - ${state.errorMessage}');
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
                                  log('🔄 NOTES: Retrying to load notes...');
                                  context.read<NotesBloc>().add(LoadNotes());
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (state.notes.isEmpty) {
                      log('📝 NOTES: No notes found - showing empty state');
                      return const _EmptyNotesView();
                    }
                    
                    log('✅ NOTES: Showing ${state.notes.length} notes');
                    return _NotesList(notes: state.notes);
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
  const _EmptyNotesView();

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
              'Aún no tienes notas',
              style: GoogleFonts.interTight(
                textStyle: Theme.of(context).textTheme.headlineSmall,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón de abajo para crear tu primera nota y guardar tus pensamientos.',
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

class _NotesList extends StatelessWidget {
  final List<Note> notes;
  const _NotesList({required this.notes});

  @override
  Widget build(BuildContext context) {
    log('📝 NOTES LIST: Building list with ${notes.length} notes');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        log('📝 NOTES LIST: Building note ${index + 1}: "${note.title}"');
        return _NoteCard(note: note)
            .animate()
            .fadeIn(delay: (100 + index * 50).ms)
            .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  const _NoteCard({required this.note});

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
        onTap: () async {
          HapticFeedback.lightImpact();
          final result = await context.pushNamed('note_detail', extra: note);
          
          if (result != null && result is Map<String, dynamic> && context.mounted) {
            final action = result['action'];
            final noteId = result['noteId'];
            
            if (action == 'update') {
              final content = result['content'];
              context.read<NotesBloc>().add(UpdateExistingNote(
                noteId: noteId,
                content: content,
              ));
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: GoogleFonts.inter(
                  textStyle: textTheme.titleLarge,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryText.withAlpha(160),
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
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
      ),
    );
  }
}

class _AddNoteFAB extends StatelessWidget {
  const _AddNoteFAB();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        HapticFeedback.lightImpact();
        final result = await context.pushNamed('create_note');
        
        // Si se creó una nota exitosamente, recargar la lista
        if (result == true && context.mounted) {
          log('📝 NOTES: Note created successfully, reloading list...');
          context.read<NotesBloc>().add(LoadNotes());
        }
      },
      shape: const CircleBorder(),
      backgroundColor: AppTheme.primaryColor,
      elevation: 8.0,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut);
  }
}