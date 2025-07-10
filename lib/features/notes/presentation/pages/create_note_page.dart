import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.creationStatus == NoteCreationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Nota guardada con éxito'),
            backgroundColor: AppTheme.primaryColor,
          ));
          context.pop(true);
        }
        if (state.creationStatus == NoteCreationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage ?? 'No se pudo guardar la nota.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryText, size: 30),
              onPressed: () => context.pop(),
            ),
            title: Text('Crea una nueva nota', style: GoogleFonts.interTight(textStyle: textTheme.titleLarge)),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.alternate, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Título',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.alternate,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              decoration: const InputDecoration(
                                hintText: 'Escribe aquí tu nota...',
                                border: InputBorder.none,
                              ),
                              style: textTheme.bodyLarge?.copyWith(height: 1.5),
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              expands: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<NotesBloc, NotesState>(
                    builder: (context, state) {
                      return state.creationStatus == NoteCreationStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              onPressed: () {
                                context.read<NotesBloc>().add(AddNewNote(
                                      title: _titleController.text,
                                      content: _contentController.text,
                                    ));
                              },
                              text: 'Guardar nota',
                              options: ButtonOptions(
                                width: double.infinity,
                                height: 50,
                                color: AppTheme.primaryColor,
                                textStyle: GoogleFonts.inter(textStyle: textTheme.titleSmall, color: Colors.white, fontWeight: FontWeight.w600),
                                elevation: 3,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}