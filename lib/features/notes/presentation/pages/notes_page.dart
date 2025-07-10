import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es_ES');
    return BlocProvider(
      create: (context) => getIt<NotesBloc>()..add(LoadNotes()),
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
                child: BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    if (state.status == NotesStatus.loading || state.status == NotesStatus.initial) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state.status == NotesStatus.error) {
                      return Center(child: Text(state.errorMessage ?? 'Error al cargar las notas'));
                    }
                    if (state.notes.isEmpty) {
                      return const _EmptyNotesView();
                    }
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
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
        onTap: () {
          context.pushNamed('note_detail', extra: note);
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
      onPressed: () {
        HapticFeedback.lightImpact();
        context.pushNamed('create_note');
      },
      shape: const CircleBorder(),
      backgroundColor: AppTheme.primaryColor,
      elevation: 8.0,
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    ).animate().scale(delay: 500.ms, duration: 500.ms, curve: Curves.elasticOut);
  }
}