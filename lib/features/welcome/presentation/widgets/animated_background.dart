import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../app/theme.dart';

const double _kLargeBlobMinSpeed = 0.8;
const double _kLargeBlobMaxSpeed = 1.4;
const double _kSmallBlobMinSpeed = 1.2;
const double _kSmallBlobMaxSpeed = 2.2;
const int _kShapeChangeDurationMs = 500;


class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Blob> _blobs;

  @override
  void initState() {
    super.initState();

    final List<Color> colorPalette = [
      AppTheme.primaryColor,
      AppTheme.lightTheme.inputDecorationTheme.focusedBorder!.borderSide.color,
      AppTheme.alternate.withAlpha(204),
      AppTheme.primaryColor.withAlpha(127),
    ];

    _blobs = List.generate(12, (index) {
      final bool isLarge = index < 4;
      return _Blob.create(isLarge, colorPalette);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.addListener(_updateBlobs);
    _controller.repeat();
  }

  void _updateBlobs() {
    if (mounted) {
      setState(() {
        for (final blob in _blobs) {
          blob.move();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateBlobs);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        for (final blob in _blobs) {
          blob.setScreenBounds(constraints);
        }

        return Stack(
          children: _blobs.map((blob) {
            if (blob.position == null) {
              return const SizedBox.shrink();
            }
            
            return Positioned(
              left: blob.position!.dx,
              top: blob.position!.dy,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: _kShapeChangeDurationMs),
                curve: Curves.ease,
                width: blob.size,
                height: blob.size,
                decoration: BoxDecoration(
                  color: blob.color,
                  borderRadius: blob.borderRadius,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Blob {
  Size? _screenSize;
  Offset? position;
  late Offset velocity;
  late double size;
  late Color color;
  late BorderRadius borderRadius;
  final Random _random = Random();

  _Blob.create(bool isLarge, List<Color> colorPalette) {
    size = isLarge
        ? 250 + _random.nextDouble() * 200
        : 20 + _random.nextDouble() * 50;

    final minSpeed = isLarge ? _kLargeBlobMinSpeed : _kSmallBlobMinSpeed;
    final maxSpeed = isLarge ? _kLargeBlobMaxSpeed : _kSmallBlobMaxSpeed;

    double randomSpeed() => minSpeed + _random.nextDouble() * (maxSpeed - minSpeed);
        
    velocity = Offset(
      (_random.nextBool() ? 1 : -1) * randomSpeed(),
      (_random.nextBool() ? 1 : -1) * randomSpeed(),
    );
    
    color = colorPalette[_random.nextInt(colorPalette.length)].withAlpha(isLarge ? 153 : 230);
    
    _randomizeShape();
  }

  void setScreenBounds(BoxConstraints constraints) {
    if (_screenSize == null) {
      _screenSize = constraints.biggest;
      final startAreaWidth = _screenSize!.width + size * 2;
      final startAreaHeight = _screenSize!.height + size * 2;
      
      position = Offset(
        _random.nextDouble() * startAreaWidth - size,
        _random.nextDouble() * startAreaHeight - size,
      );
    }
  }

  void _randomizeShape() {
    borderRadius = BorderRadius.circular(size / 2).copyWith(
      topLeft: Radius.circular(size * (0.4 + _random.nextDouble() * 0.5)),
      topRight: Radius.circular(size * (0.4 + _random.nextDouble() * 0.5)),
      bottomLeft: Radius.circular(size * (0.4 + _random.nextDouble() * 0.5)),
      bottomRight: Radius.circular(size * (0.4 + _random.nextDouble() * 0.5)),
    );
  }

  void move() {
    if (_screenSize == null || position == null) return;

    bool bounced = false;
    double newVx = velocity.dx;
    double newVy = velocity.dy;
    
    double varySpeed(double originalSpeed) {
      return originalSpeed * (0.8 + _random.nextDouble() * 0.4);
    }

    if (position!.dx <= -size / 2 || position!.dx + size / 2 >= _screenSize!.width) {
      newVx = -velocity.dx;
      newVy = varySpeed(velocity.dy);
      bounced = true;
    }
    if (position!.dy <= -size / 2 || position!.dy + size / 2 >= _screenSize!.height) {
      newVy = -velocity.dy;
      newVx = varySpeed(velocity.dx);
      bounced = true;
    }

    if (bounced) {
      velocity = Offset(newVx, newVy);
    }
    
    position = position! + velocity;

    if (_random.nextDouble() < 0.005) {
      _randomizeShape();
    }
  }
}