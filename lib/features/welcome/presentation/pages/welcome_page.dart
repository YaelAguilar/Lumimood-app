import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/di.dart';
import '../../../../../app/theme.dart';
import '../bloc/welcome_bloc.dart';
import '../widgets/widgets.dart';

const double _kBackgroundBlur = 50.0;

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WelcomeBloc>(),
      child: const _WelcomeView(),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _kBackgroundBlur, sigmaY: _kBackgroundBlur),
            child: const SizedBox.shrink(),
          ),
          const _Content(),
        ],
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool _isLoading = false;
  WelcomeEvent? _triggeredEvent;
  double _buttonScale = 1.0;

  void _initiateNavigation(WelcomeEvent event) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _triggeredEvent = event;
    });

    HapticFeedback.lightImpact();
    context.read<WelcomeBloc>().add(event);
    
  }
  
  Future<void> _navigateAfterAnimation() async {
    if (!mounted || _triggeredEvent == null) return;

    if (_triggeredEvent is LoginButtonPressed) {
      await context.pushNamed('login');
    } else if (_triggeredEvent is RegisterButtonPressed) {
      await context.pushNamed('register');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _triggeredEvent = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Hero(
              tag: 'logo_hero',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withAlpha(220),
                  shape: BoxShape.circle,
                  boxShadow: [ BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 20, spreadRadius: 5) ]
                ),
                child: Center(child: Text('L', style: GoogleFonts.notoSans(textStyle: textTheme.displayLarge, color: AppTheme.primaryColor))),
              ),
            )
            .animate(onComplete: (controller) => controller.repeat(reverse: true))
            .scale(duration: 2500.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeInOut)
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
            
            const SizedBox(height: 44),
            
            AnimatedOpacity(
              opacity: _isLoading ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              onEnd: () {
                if (_isLoading) {
                  _navigateAfterAnimation();
                }
              },
              child: Column(
                children: [
                  Text('Bienvenido a Lumimood', style: textTheme.displaySmall),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Tu viaje hacia el bienestar emocional comienza aquí. Accede o crea tu cuenta.',
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium.override(color: AppTheme.primaryText.withAlpha(179)),
                    ),
                  ),
                ],
              ).animate(delay: 400.ms).fadeIn().moveY(begin: 20, curve: Curves.easeOut),
            ),
            
            const Spacer(flex: 3),

            GestureDetector(
              onTapDown: (_) => setState(() => _buttonScale = 0.95),
              onTapUp: (_) {
                setState(() => _buttonScale = 1.0);
                _initiateNavigation(LoginButtonPressed());
              },
              onTapCancel: () => setState(() => _buttonScale = 1.0),
              child: AnimatedScale(
                scale: _buttonScale,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    // Asegurarse que el color no cambie al estar deshabilitado
                    disabledBackgroundColor: AppTheme.primaryColor,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoading && _triggeredEvent is LoginButtonPressed
                        ? const SizedBox(key: ValueKey('loader'), width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text('Iniciar sesión', key: const ValueKey('text'), style: textTheme.titleSmall.override(color: Colors.white)),
                  ),
                ),
              ),
            )
            .animate()
            .slideY(begin: 1, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutCubic)
            .fadeIn(),

            const SizedBox(height: 16),
            if (!_isLoading)
              TextButton(
                onPressed: () => _initiateNavigation(RegisterButtonPressed()),
                child: Text('Crear una cuenta nueva', style: textTheme.bodyMedium.override(fontWeight: FontWeight.w600, color: AppTheme.primaryText.withAlpha(220))),
              ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}