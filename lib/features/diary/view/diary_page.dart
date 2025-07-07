import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../ui/shared_widgets/custom_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/text_style_extensions.dart';
import '../viewmodel/diary_viewmodel.dart';
import '../widgets/emotion_button.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiaryViewModel(),
      child: Consumer<DiaryViewModel>(
        builder: (context, viewModel, child) {
          final theme = AppTheme.of(context);
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              key: GlobalKey<ScaffoldState>(),
              backgroundColor: const Color(0xFFF5FBFB),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: theme.primaryText),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              drawer: _buildDrawer(context),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          '¿Cómo te sientes hoy?',
                          style: theme.headlineMedium.override(
                            fontFamily: GoogleFonts.readexPro().fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildEmotionsList(context, viewModel),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildNoteCard(context, viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmotionsList(BuildContext context, DiaryViewModel viewModel) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.emotions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final emotion = viewModel.emotions[index];
          return EmotionButton(
            emotion: emotion,
            onPressed: () => viewModel.onEmotionTapped(context, emotion),
          );
        },
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, DiaryViewModel viewModel) {
    final theme = AppTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // <-- CORREGIDO
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: viewModel.titleController,
            focusNode: viewModel.titleFocusNode,
            decoration: const InputDecoration(hintText: 'Título'),
            style: theme.labelMedium,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.contentController,
            focusNode: viewModel.contentFocusNode,
            decoration: const InputDecoration(
                hintText: 'Escribe acerca de tu día, pensamientos...'),
            style: theme.labelMedium,
            maxLines: 4,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              viewModel.saveNote();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            text: 'Guardar nota',
            options: ButtonOptions(
              width: double.infinity,
              height: 48,
              color: theme.primaryColor,
              textStyle: theme.titleSmall.override(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = AppTheme.of(context);
    return Drawer(
      elevation: 16,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor.withAlpha(26)),
            child: Center(
              child: Text(
                'Lumimood',
                style: theme.displaySmall.override(
                  color: theme.primaryColor,
                  fontFamily: GoogleFonts.interTight().fontFamily,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: Text('Diario', style: theme.titleSmall),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text('Estadísticas', style: theme.titleSmall),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}