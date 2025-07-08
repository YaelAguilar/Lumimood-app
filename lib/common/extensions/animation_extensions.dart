import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimationInfo {
  final AnimationTrigger trigger;
  final List<Effect> Function() effectsBuilder;
  AnimationInfo({required this.trigger, required this.effectsBuilder});
}

enum AnimationTrigger { onPageLoad }

extension AnimateOnPageLoadExtension on Widget {
  Widget animateOnPageLoad(AnimationInfo? animationInfo) {
    if (animationInfo == null) return this;
    final effects = animationInfo.effectsBuilder();
    return animate().addEffects(effects);
  }
}