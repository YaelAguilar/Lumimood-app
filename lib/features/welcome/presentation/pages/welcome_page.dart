import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../bloc/welcome_bloc.dart';
import '../widgets/animated_background.dart';

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
    return BlocListener<WelcomeBloc, WelcomeState>(
      listener: (context, state) {
        if (state is WelcomeNavigateToLogin) {
          context.pushNamed('login');
        } else if (state is WelcomeNavigateToRegister) {
          context.pushNamed('register');
        }
      },
      child: const Scaffold(
        body: Stack(
          children: [
            AnimatedBackground(),
            _WelcomeContent(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            const _WelcomeIllustration(),
            const SizedBox(height: 40),
            const _WelcomeHeader(),
            const Spacer(flex: 3),
            const _ActionButtons(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo_hero',
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.24),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(50, 50),
            painter: _LeafPainter(),
          ),
        ),
      ),
    )
    .animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutCubic)
    .slideY(begin: 0.2, duration: 1000.ms, curve: Curves.easeOutCubic)
    .animate(onComplete: (c) => c.repeat(reverse: true))
    .scale(
      duration: 6.seconds,
      curve: Curves.easeInOut,
      begin: const Offset(1, 1),
      end: const Offset(1.04, 1.04),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Bienvenido a Lumimood',
          textAlign: TextAlign.center,
          style: GoogleFonts.interTight(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Gracias por unirte a Lumimood.\nAccede o crea tu cuenta, y empieza con este viaje',
          textAlign: TextAlign.center,
          style: GoogleFonts.interTight(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText.withValues(alpha: 0.75),
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 1000.ms).slideY(begin: 0.3);
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
          onPressed: () => context.read<WelcomeBloc>().add(RegisterButtonPressed()),
          child: Text(
            'Empezar ahora',
            style: GoogleFonts.interTight(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryText.withValues(alpha: 0.8),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => context.read<WelcomeBloc>().add(LoginButtonPressed()),
          child: Text(
            'Ya tengo una cuenta',
            style: GoogleFonts.interTight(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms, duration: 1000.ms).slideY(begin: 0.3);
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.5, size.height * 0.4);

    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.2,
    );

    path.moveTo(size.width * 0.5, size.height * 0.4);

    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}