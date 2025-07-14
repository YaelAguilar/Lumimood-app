import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/emotion.dart';

class EmotionButton extends StatefulWidget {
  final Emotion emotion;
  final bool isSelected;
  final VoidCallback onPressed;

  const EmotionButton({
    super.key,
    required this.emotion,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<EmotionButton> createState() => _EmotionButtonState();
}

class _EmotionButtonState extends State<EmotionButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getEmojiForEmotion(String emotionName) {
    // Convertir a lowercase y buscar coincidencias más amplias
    final emotion = emotionName.toLowerCase().trim();
    
    switch (emotion) {
      case 'felicidad':
      case 'feliz':
      case 'alegría':
      case 'alegre':
      case 'contento':
      case 'happy':
        return '😊';
        
      case 'tristeza':
      case 'triste':
      case 'melancólico':
      case 'deprimido':
      case 'sad':
        return '😢';
        
      case 'ansiedad':
      case 'ansioso':
      case 'nervioso':
      case 'preocupado':
      case 'anxiety':
        return '😰';
        
      case 'enojo':
      case 'enojado':
      case 'ira':
      case 'molesto':
      case 'furioso':
      case 'angry':
        return '😠';
        
      case 'miedo':
      case 'temor':
      case 'asustado':
      case 'temeroso':
      case 'fear':
        return '😨';
        
      case 'calma':
      case 'calmado':
      case 'tranquilo':
      case 'sereno':
      case 'relajado':
      case 'paz':
      case 'calm':
        return '😌';
        
      case 'estrés':
      case 'estresado':
      case 'agobiado':
      case 'abrumado':
      case 'stress':
        return '😵';
        
      case 'sorprendido':
      case 'sorpresa':
      case 'asombrado':
      case 'surprised':
        return '😲';
        
      case 'emocionado':
      case 'emoción':
      case 'entusiasmado':
      case 'excited':
        return '🤗';
        
      case 'confundido':
      case 'confusión':
      case 'perdido':
      case 'confused':
        return '😕';
        
      case 'disgustado':
      case 'disgusto':
      case 'asco':
      case 'repugnancia':
      case 'disgusted':
        return '🤢';
        
      case 'aburrido':
      case 'aburrimiento':
      case 'tedioso':
      case 'bored':
        return '😴';
        
      case 'esperanza':
      case 'esperanzado':
      case 'optimista':
      case 'hopeful':
        return '🌟';
        
      case 'gratitud':
      case 'agradecido':
      case 'grateful':
        return '🙏';
        
      case 'amor':
      case 'cariño':
      case 'enamorado':
      case 'love':
        return '😍';
        
      default:
        // Si no encuentra coincidencia, mostrar emoji neutral
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emoji = _getEmojiForEmotion(widget.emotion.name);
    
    return GestureDetector(
      onTapDown: (_) {
        _animationController.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _animationController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.isSelected)
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                widget.emotion.color.withValues(alpha: 0.3),
                                widget.emotion.color.withValues(alpha: 0.1),
                                widget.emotion.color.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        ).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2),
                          duration: 2000.ms,
                          curve: Curves.easeInOut,
                        ),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: widget.isSelected ? 90 : 75,
                        height: widget.isSelected ? 90 : 75,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.emotion.color,
                              widget.emotion.color.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (widget.isSelected) ...[
                              BoxShadow(
                                color: widget.emotion.color.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: widget.emotion.color.withValues(alpha: 0.2),
                                blurRadius: 40,
                                spreadRadius: 0,
                                offset: const Offset(0, 16),
                              ),
                            ] else ...[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      if (widget.isSelected)
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      
                      // Emoji
                      SizedBox(
                        width: widget.isSelected ? 50 : 40,
                        height: widget.isSelected ? 50 : 40,
                        child: Center(
                          child: Text(
                            emoji,
                            style: TextStyle(
                              fontSize: widget.isSelected ? 32 : 26,
                            ),
                          ),
                        ),
                      ),
                      
                      if (widget.isSelected)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: widget.emotion.color,
                            ),
                          ),
                        ).animate().scale(
                          delay: 100.ms,
                          curve: Curves.elasticOut,
                          duration: 400.ms,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isSelected ? 12 : 8,
                      vertical: widget.isSelected ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isSelected 
                          ? widget.emotion.color.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: widget.isSelected
                          ? Border.all(
                              color: widget.emotion.color.withValues(alpha: 0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      widget.emotion.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.w500,
                        color: widget.isSelected ? widget.emotion.color : Colors.grey[700],
                        fontSize: widget.isSelected ? 14 : 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate(target: widget.isSelected ? 1 : 0)
      .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 200.ms,
        curve: Curves.easeOutBack,
      );
  }
}