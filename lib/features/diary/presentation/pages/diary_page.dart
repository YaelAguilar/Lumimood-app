// lib/features/diary/presentation/pages/diary_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../bloc/diary_bloc.dart';
import '../widgets/emotion_button.dart';

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

class _DiaryView extends StatefulWidget {
  const _DiaryView();

  @override
  State<_DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<_DiaryView> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    _autoScrollTimer = Timer(const Duration(seconds: 1), () {
      _scrollToEmotionsSection();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _scrollToEmotionsSection() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        250.0,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiaryBloc, DiaryState>(
      listener: (context, state) {
        if (state.isNoteSaved) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Nota guardada con éxito'),
                  ],
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          drawer: const _DiaryDrawer(),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Container(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE0FBFD), Color(0xFFC4F2C2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ModernHeader(),
                            const Spacer(),
                            _WelcomeCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Column(
                    children: [
                      const _EmotionsSection(),
                      const SizedBox(height: 24),
                      const _NoteSection(),
                      const SizedBox(height: 40),
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
}

class _ModernHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(102)),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(102)),
          ),
          child: IconButton(
            icon: Icon(Icons.menu_rounded, color: AppTheme.primaryText, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2);
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final timeOfDay = now.hour < 12 ? 'Buenos días' :
                      now.hour < 18 ? 'Buenas tardes' : 'Buenas noches';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(153)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timeOfDay,
            style: GoogleFonts.interTight(
              textStyle: textTheme.titleMedium,
              color: AppTheme.primaryText.withAlpha(179),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Cómo te sientes hoy?',
            style: GoogleFonts.interTight(
              textStyle: textTheme.headlineMedium,
              color: AppTheme.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3);
  }
}

class _EmotionsSection extends StatelessWidget {
  const _EmotionsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sentiment_satisfied_alt,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Selecciona tu emoción',
                style: GoogleFonts.interTight(
                  textStyle: textTheme.titleLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _EmotionsList(),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }
}

class _EmotionsList extends StatelessWidget {
  const _EmotionsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiaryBloc, DiaryState>(
      buildWhen: (p, c) => p.emotions != c.emotions || p.selectedEmotion != c.selectedEmotion,
      builder: (context, state) {
        if (state.status == DiaryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == DiaryStatus.error) {
          return Center(child: Text(state.errorMessage ?? 'Error al cargar'));
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: state.emotions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final emotion = state.emotions[index];
              return EmotionButton(
                emotion: emotion,
                isSelected: state.selectedEmotion == emotion,
                onPressed: () => context.read<DiaryBloc>().add(EmotionSelected(emotion)),
              ).animate(delay: (index * 100).ms).scale(curve: Curves.easeOutBack);
            },
          ),
        );
      },
    );
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Escribe tu día',
                style: GoogleFonts.interTight(
                  textStyle: textTheme.titleLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _NoteCard(),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2);
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
    final textTheme = Theme.of(context).textTheme;
    
    return BlocBuilder<DiaryBloc, DiaryState>(
      buildWhen: (p, c) => p.selectedEmotion != c.selectedEmotion,
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: state.selectedEmotion?.color.withAlpha(13) ?? Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: state.selectedEmotion?.color.withAlpha(51) ?? AppTheme.alternate,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Dale un título a tu día',
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      Icons.title,
                      color: state.selectedEmotion?.color ?? AppTheme.primaryColor,
                    ),
                  ),
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'Escribe sobre tus pensamientos, eventos, lo que quieras...',
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    alignLabelWithHint: true,
                  ),
                  style: textTheme.bodyLarge,
                  maxLines: 6,
                  minLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              
              const SizedBox(height: 24),
              
              BlocListener<DiaryBloc, DiaryState>(
                listener: (context, state) {
                  if (state.isNoteSaved) {
                    _titleController.clear();
                    _contentController.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        state.selectedEmotion?.color ?? AppTheme.primaryColor,
                        (state.selectedEmotion?.color ?? AppTheme.primaryColor).withAlpha(204),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (state.selectedEmotion?.color ?? AppTheme.primaryColor).withAlpha(51),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.read<DiaryBloc>().add(SaveNoteButtonPressed(
                              title: _titleController.text,
                              content: _contentController.text,
                            ));
                      },
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.save, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Guardar Nota',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DiaryDrawer extends StatelessWidget {
  const _DiaryDrawer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0FBFD), Color(0xFFC4F2C2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo_hero',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'L',
                          style: GoogleFonts.notoSans(
                            textStyle: textTheme.displayMedium,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lumimood',
                    style: GoogleFonts.interTight(
                      textStyle: textTheme.titleLarge,
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _DrawerItem(
                      icon: Icons.book_outlined,
                      title: 'Diario',
                      isSelected: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _DrawerItem(
                      icon: Icons.bar_chart_outlined,
                      title: 'Estadísticas',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed('statistics');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.task_outlined,
                      title: 'Tareas',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed('tasks');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.note_outlined,
                      title: 'Notas',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed('notes');
                      },
                    ),
                    const Divider(height: 32),
                    _DrawerItem(
                      icon: Icons.logout,
                      title: 'Cerrar sesión',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushReplacementNamed('welcome');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withAlpha(26) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}