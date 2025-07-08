import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../bloc/diary_bloc.dart';
import '../widgets/emotion_button.dart';
import '../../../../common/widgets/custom_button.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DiaryBloc>(),
      child: const _DiaryView(),
    );
  }
}

class _DiaryView extends StatelessWidget {
  const _DiaryView();

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.lightTheme.textTheme;

    return BlocListener<DiaryBloc, DiaryState>(
      listener: (context, state) {
        if (state.selectedEmotion != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Seleccionaste: ${state.selectedEmotion!.name}'),
                backgroundColor: state.selectedEmotion!.color,
              ),
            );
        }
        if (state.isNoteSaved) {
           ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Nota guardada con éxito'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: AppTheme.primaryText),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: const _DiaryDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text('¿Cómo te sientes hoy?', style: textTheme.headlineMedium),
                ),
                const SizedBox(height: 32),
                const _EmotionsList(),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: _NoteCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionsList extends StatelessWidget {
  const _EmotionsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      builder: (context, state) {
        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            scrollDirection: Axis.horizontal,
            itemCount: state.emotions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final emotion = state.emotions[index];
              return EmotionButton(
                emotion: emotion,
                onPressed: () => context.read<DiaryBloc>().add(EmotionSelected(emotion)),
              );
            },
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatefulWidget {
  const _NoteCard();

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
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
    final textTheme = AppTheme.lightTheme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))], // <-- CAMBIADO
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Título'), style: textTheme.labelMedium),
          const SizedBox(height: 16),
          TextField(controller: _contentController, decoration: const InputDecoration(hintText: 'Escribe acerca de tu día...'), style: textTheme.labelMedium, maxLines: 4),
          const SizedBox(height: 16),
          BlocListener<DiaryBloc, DiaryState>(
            listener: (context, state) {
              if (state.isNoteSaved) {
                _titleController.clear();
                _contentController.clear();
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: CustomButton(
              onPressed: () {
                context.read<DiaryBloc>().add(SaveNoteButtonPressed(
                      title: _titleController.text,
                      content: _contentController.text,
                    ));
              },
              text: 'Guardar nota',
              options: ButtonOptions(
                width: double.infinity,
                height: 48,
                color: AppTheme.primaryColor,
                textStyle: textTheme.titleSmall!.override(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryDrawer extends StatelessWidget {
  const _DiaryDrawer();

  @override
  Widget build(BuildContext context) {
    final textTheme = AppTheme.lightTheme.textTheme;
    return Drawer(
      elevation: 16,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(26)),
            child: Center(child: Text('Lumimood', style: textTheme.displaySmall!.override(color: AppTheme.primaryColor))),
          ),
          ListTile(leading: const Icon(Icons.book), title: Text('Diario', style: textTheme.titleSmall), onTap: () => Navigator.of(context).pop()),
          ListTile(leading: const Icon(Icons.bar_chart), title: Text('Estadísticas', style: textTheme.titleSmall), onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}