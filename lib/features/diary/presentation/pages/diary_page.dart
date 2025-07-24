import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../bloc/diary_bloc.dart';
import '../widgets/emotion_button.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DiaryBloc>()..add(LoadInitialData()),
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
  @override
  Widget build(BuildContext context) {
    return BlocListener<DiaryBloc, DiaryState>(
      listener: (context, state) {
        final errorMessage = state.errorMessage;
        if (errorMessage != null && errorMessage.isNotEmpty) {
           ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
              ),
            );
        }
        if (state.isEmotionSaved) {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Emoción guardada con éxito'),
                  ],
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          drawer: const _DiaryDrawer(),
          body: Stack(
            children: [
              const AnimatedBackground(),
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    elevation: 0,
                    backgroundColor: AppTheme.scaffoldBackground.withAlpha((0.8 * 255).round()),
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu_rounded, color: AppTheme.primaryText, size: 28),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    title: Text(
                      'Mi Diario',
                      style: GoogleFonts.interTight(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.insights, color: AppTheme.primaryText),
                        onPressed: () => context.pushNamed('statistics'),
                        tooltip: 'Ver estadísticas',
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        const _WelcomeCard(),
                        const SizedBox(height: 24),
                        const _EmotionsSection(),
                        const SizedBox(height: 24),
                        const _RecentNotesSection(),
                        const SizedBox(height: 40),
                      ],
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

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final timeOfDay = now.hour < 12
        ? 'Buenos días'
        : now.hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    final greeting = now.hour < 12
        ? '🌅'
        : now.hour < 18
            ? '☀️'
            : '🌙';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withAlpha((0.95 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  timeOfDay,
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.titleMedium,
                    color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '¿Cómo te sientes hoy?',
              style: GoogleFonts.interTight(
                textStyle: textTheme.headlineMedium,
                color: AppTheme.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona tu emoción y registra tu estado actual',
              style: GoogleFonts.interTight(
                textStyle: textTheme.bodyMedium,
                color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
    );
  }
}

class _EmotionsSection extends StatefulWidget {
  const _EmotionsSection();

  @override
  State<_EmotionsSection> createState() => _EmotionsSectionState();
}

class _EmotionsSectionState extends State<_EmotionsSection> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  int _totalEmotions = 0;
  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && _totalEmotions > 0 && !_isScrollingProgrammatically) {
      final double itemWidth = 125.0;
      final double offset = _scrollController.offset;
      final double viewportWidth = _scrollController.position.viewportDimension;
      
      final double centerOffset = offset + (viewportWidth / 2) - 16;
      int newPage = (centerOffset / itemWidth).round().clamp(0, _totalEmotions - 1);
      
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    }
  }

  void _scrollToEmotion(int emotionIndex) {
    if (_scrollController.hasClients && emotionIndex >= 0 && emotionIndex < _totalEmotions) {
      _isScrollingProgrammatically = true;
      
      final double itemWidth = 125.0;
      final double viewportWidth = _scrollController.position.viewportDimension;
      final double targetOffset = (emotionIndex * itemWidth) - (viewportWidth / 2) + (itemWidth / 2) + 16;
      
      final double maxOffset = _scrollController.position.maxScrollExtent;
      final double clampedOffset = targetOffset.clamp(0.0, maxOffset);
      
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ).then((_) {
        setState(() {
          _currentPage = emotionIndex;
          _isScrollingProgrammatically = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                        AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.sentiment_satisfied_alt, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona tu emoción',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Desliza para ver más opciones',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.bodySmall,
                          color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: BlocConsumer<DiaryBloc, DiaryState>(
                  listener: (context, state) {
                    if (state.selectedEmotion != null && state.emotions.isNotEmpty) {
                      final emotionIndex = state.emotions.indexOf(state.selectedEmotion!);
                      if (emotionIndex != -1 && emotionIndex != _currentPage) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToEmotion(emotionIndex);
                        });
                      }
                    }
                  },
                  buildWhen: (p, c) => p.emotions != c.emotions || p.selectedEmotion != c.selectedEmotion || p.status != c.status,
                  builder: (context, state) {
                    if (state.status == DiaryStatus.loading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (state.status == DiaryStatus.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                state.errorMessage ?? 'Error al cargar emociones',
                                style: TextStyle(color: Colors.red[300]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_totalEmotions != state.emotions.length) {
                        setState(() {
                          _totalEmotions = state.emotions.length;
                        });
                      }
                    });

                    return ListView.separated(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.emotions.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 5),
                      itemBuilder: (context, index) {
                        final emotion = state.emotions[index];
                        return EmotionButton(
                          emotion: emotion,
                          isSelected: state.selectedEmotion == emotion,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            context.read<DiaryBloc>().add(EmotionSelected(emotion));
                          },
                        ).animate(delay: (index * 100).ms).scale(curve: Curves.easeOutBack);
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_totalEmotions > 1)
              BlocBuilder<DiaryBloc, DiaryState>(
                buildWhen: (p, c) => p.selectedEmotion != c.selectedEmotion,
                builder: (context, state) {
                  int selectedEmotionPage = _currentPage;
                  if (state.selectedEmotion != null && state.emotions.isNotEmpty) {
                    final emotionIndex = state.emotions.indexOf(state.selectedEmotion!);
                    if (emotionIndex != -1) {
                      selectedEmotionPage = emotionIndex;
                    }
                  }

                  return Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_totalEmotions, (index) {
                        final isActive = index == selectedEmotionPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                          ),
                        ).animate(target: isActive ? 1 : 0)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 200.ms,
                          );
                      }),
                    ),
                  );
                },
              ),
            
            // Intensity Slider Section
            const SizedBox(height: 24),
            BlocBuilder<DiaryBloc, DiaryState>(
              buildWhen: (p, c) => p.selectedEmotion != c.selectedEmotion || p.intensity != c.intensity,
              builder: (context, state) {
                if (state.selectedEmotion == null) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intensidad: ${state.intensity.round()}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: state.selectedEmotion?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: state.intensity,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: state.selectedEmotion?.color,
                      label: state.intensity.round().toString(),
                      onChanged: (value) {
                        context.read<DiaryBloc>().add(IntensityChanged(value));
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.selectedEmotion?.color ?? AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: (state.selectedEmotion?.color ?? AppTheme.primaryColor).withAlpha((0.4 * 255).round()),
                        ),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.read<DiaryBloc>().add(SaveEmotionButtonPressed());
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          'Guardar Emoción',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms);
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
    );
  }
}

class _RecentNotesSection extends StatefulWidget {
  const _RecentNotesSection();

  @override
  State<_RecentNotesSection> createState() => _RecentNotesSectionState();
}

class _RecentNotesSectionState extends State<_RecentNotesSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.06 * 255).round()),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                        AppTheme.primaryColor.withAlpha((0.05 * 255).round()),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.library_books, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas Recientes',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tus últimas reflexiones',
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.bodySmall,
                          color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.pushNamed('notes'),
                  child: Text(
                    'Ver todas',
                    style: GoogleFonts.interTight(
                      textStyle: textTheme.bodyMedium,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<DiaryBloc, DiaryState>(
              buildWhen: (p, c) => p.recentNotes != c.recentNotes || p.status != c.status,
              builder: (context, state) {
                if (state.status == DiaryStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (state.recentNotes.isEmpty) {
                  return _EmptyNotesWidget();
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: state.recentNotes.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final note = state.recentNotes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: _NoteCarouselCard(note: note),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Page Indicator (Dots)
                    if (state.recentNotes.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.recentNotes.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? AppTheme.primaryColor 
                                  : AppTheme.primaryColor.withAlpha((0.3 * 255).round()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
    );
  }
}

class _EmptyNotesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No tienes notas aún',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera nota tocando aquí',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _NoteCarouselCard extends StatelessWidget {
  final Note note;
  
  const _NoteCarouselCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = DateFormat.yMMMd('es_ES').format(note.date);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pushNamed('note_detail', extra: note);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: GoogleFonts.interTight(
                      textStyle: textTheme.titleMedium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.inter(
                      textStyle: textTheme.bodySmall,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                note.content,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Leer más',
                  style: GoogleFonts.inter(
                    textStyle: textTheme.bodySmall,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFFBBDEFB),
                  Color(0xFF90CAF9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
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
                          color: Colors.black.withAlpha((0.1 * 255).round()),
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
                Text(
                  'Tu diario emocional',
                  style: GoogleFonts.interTight(
                    textStyle: textTheme.bodyMedium,
                    color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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
                  icon: Icons.insights_outlined,
                  title: 'Estadísticas',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.pushNamed('statistics');
                  },
                ),
                _DrawerItem(
                  icon: Icons.task_alt_outlined,
                  title: 'Tareas',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.pushNamed('tasks');
                  },
                ),
                _DrawerItem(
                  icon: Icons.note_alt_outlined,
                  title: 'Notas',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.pushNamed('notes');
                  },
                ),
                const Divider(height: 32),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                _DrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Cerrar sesión',
                  onTap: () {
                    context.read<SessionCubit>().signOut();
                    context.goNamed('welcome');
                  },
                ),
              ],
            ),
          ),
        ],
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
        color: isSelected ? AppTheme.primaryColor.withAlpha((0.1 * 255).round()) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}