import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  static const List<List<Color>> _colorSets = [
    [Color(0xFFE0FBFD), Color(0xFFB8EAD9)],
    [Color(0xFFC4F2C2), Color(0xFFD6F9FB)],
    [Color(0xFFB8EAD9), Color(0xFF63DA5C)], // Establecer como fondo del sidebar
    [Color(0xFFE0FBFD), Color(0xFF06D5CD)],
  ];

  static const List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomRight,
    Alignment.bottomLeft,
  ];

  int _colorIndex = 0;
  Alignment _begin = _alignments[0];
  Alignment _end = _alignments[2];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateGradient();
    
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateGradient();
    });
  }
  
  void _updateGradient() {
    if (mounted) {
      setState(() {
        _colorIndex = (_colorIndex + 1) % _colorSets.length;
        _begin = _alignments[(_colorIndex) % _alignments.length];
        _end = _alignments[(_colorIndex + 2) % _alignments.length];
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 5), 
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colorSets[_colorIndex],
          begin: _begin,
          end: _end,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withAlpha(0)),
        ),
      ),
    );
  }
}