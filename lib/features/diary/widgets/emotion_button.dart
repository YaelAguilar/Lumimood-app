import 'package:flutter/material.dart';
import '../model/emotion_model.dart';

class EmotionButton extends StatelessWidget {
  final Emotion emotion;
  final VoidCallback onPressed;

  const EmotionButton({
    super.key,
    required this.emotion,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: emotion.color,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              elevation: 2,
            ),
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          emotion.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}