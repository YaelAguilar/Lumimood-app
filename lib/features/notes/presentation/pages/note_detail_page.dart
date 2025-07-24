import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/note.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;
  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es_ES');
    return _NoteDetailView(note: note);
  }
}

class _NoteDetailView extends StatefulWidget {
  final Note note;
  const _NoteDetailView({required this.note});

  @override
  State<_NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends State<_NoteDetailView> {
  late TextEditingController _contentController;
  bool _isEditing = false;
  late String _originalContent;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
    _originalContent = widget.note.content;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        _contentController.text = _originalContent;
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_contentController.text.trim() != _originalContent) {
      // Navegar de vuelta y pasar la información de actualización
      context.pop({
        'action': 'update',
        'noteId': widget.note.id,
        'content': _contentController.text.trim(),
      });
    } else {
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd('es_ES').add_Hms().format(widget.note.date);

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
                  'Detalle de la Nota',
                  style: GoogleFonts.interTight(
                    textStyle: Theme.of(context).textTheme.headlineSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (!_isEditing) 
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: _toggleEdit,
                      color: AppTheme.primaryText,
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _toggleEdit,
                      color: AppTheme.primaryText,
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_rounded),
                      onPressed: _saveChanges,
                      color: AppTheme.primaryColor,
                    ),
                  ]
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          style: GoogleFonts.inter(
                            textStyle: Theme.of(context).textTheme.headlineMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Creado el $formattedDate',
                              style: GoogleFonts.inter(
                                textStyle: Theme.of(context).textTheme.bodySmall,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1),
                        if (!_isEditing)
                          Text(
                            widget.note.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.primaryText.withAlpha(200),
                                  height: 1.7,
                                  fontSize: 16,
                                ),
                          )
                        else
                          TextField(
                            controller: _contentController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            autofocus: true,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.7,
                                  fontSize: 16,
                                ),
                            decoration: InputDecoration(
                              hintText: 'Contenido de la nota...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.primaryColor.withAlpha(100)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}