import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/emotion.dart';

class EmotionButton extends StatelessWidget {
  final Emotion emotion;
  final bool isSelected;
  final VoidCallback onPressed;

  const EmotionButton({
    super.key,
    required this.emotion,
    required this.isSelected,
    required this.onPressed,
  });

  String _getEmojiForEmotion(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'feliz':
        return '😊';
      case 'sorprendido':
        return '😲';
      case 'enojado':
        return '😠';
      case 'con miedo':
        return '😨';
      case 'triste':
        return '😢';
      case 'disgustado':
        return '🤢';
      default:
        return '😐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emoji = _getEmojiForEmotion(emotion.name);
    
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 90 : 75,
                  height: isSelected ? 90 : 75,
                  decoration: BoxDecoration(
                    color: emotion.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (isSelected) ...[
                        BoxShadow(
                          color: emotion.color.withAlpha(102),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: emotion.color.withAlpha(51),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 16),
                        ),
                      ] else ...[
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (isSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 45 : 35,
                  height: isSelected ? 45 : 35,
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: isSelected ? 28 : 22,
                      ),
                    ),
                  ),
                ),
                
                if (isSelected)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: emotion.color,
                      ),
                    ),
                  ).animate().scale(delay: 100.ms, curve: Curves.elasticOut),
              ],
            ),
            
            const SizedBox(height: 12),
            
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? emotion.color : Colors.grey[700],
                fontSize: isSelected ? 14 : 12,
              ) ?? const TextStyle(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? emotion.color.withAlpha(26) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  emotion.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 200.ms,
        curve: Curves.easeOutBack,
      );
  }
}