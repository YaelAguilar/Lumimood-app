import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../bloc/notes_bloc.dart';

class CreateNotePage extends StatelessWidget {
  const CreateNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotesBloc>(),
      child: const _CreateNoteView(),
    );
  }
}

class _CreateNoteView extends StatefulWidget {
  const _CreateNoteView();

  @override
  State<_CreateNoteView> createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends State<_CreateNoteView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.creationStatus == NoteCreationStatus.success) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Nota guardada con éxito'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ));
          context.pop(true);
        }
        if (state.creationStatus == NoteCreationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'No se pudo guardar la nota.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context),
          body: Stack(
            children: [
              const AnimatedBackground(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTextFields(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.scaffoldBackground.withAlpha(200),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: AppTheme.primaryText, size: 28),
        onPressed: () => context.pop(),
      ),
      title: Text('Nueva Nota', style: GoogleFonts.interTight(
        textStyle: Theme.of(context).textTheme.headlineSmall,
        fontWeight: FontWeight.bold,
      )),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Título',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_contentFocusNode);
                },
              ),
              const Divider(height: 1, thickness: 1, color: AppTheme.alternate),
              const SizedBox(height: 8),
              TextField(
                focusNode: _contentFocusNode,
                controller: _contentController,
                style: textTheme.bodyLarge?.copyWith(height: 1.6),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Escribe aquí tus pensamientos...',
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            shadowColor: AppTheme.primaryColor.withAlpha(100),
          ),
          onPressed: state.creationStatus == NoteCreationStatus.loading
              ? null
              : () {
                  context.read<NotesBloc>().add(AddNewNote(
                        title: _titleController.text,
                        content: _contentController.text,
                      ));
                },
          icon: state.creationStatus == NoteCreationStatus.loading
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            'Guardar Nota',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}