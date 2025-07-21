import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme.dart';
import '../widgets/animated_background.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(),
          _WelcomeContent(),
        ],
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const _WelcomeIllustration(),
              const SizedBox(height: 40),
              const _WelcomeHeader(),
              const SizedBox(height: 60),
              const _ActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
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
          color: Colors.white.withAlpha(210),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.primaryColor.withAlpha(80), blurRadius: 30, spreadRadius: 5)],
        ),
        child: Center(child: CustomPaint(size: const Size(50, 50), painter: _LeafPainter())),
      ),
    )
    .animate().fadeIn(duration: 1200.ms, curve: Curves.easeOutCubic)
    .slideY(begin: 0.2, duration: 1000.ms, curve: Curves.easeOutCubic)
    .animate(onComplete: (c) => c.repeat(reverse: true))
    .scale(duration: 6.seconds, curve: Curves.easeInOut, begin: const Offset(1, 1), end: const Offset(1.04, 1.04));
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Tu espacio para sentir y crecer', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: Theme.of(context).textTheme.displaySmall, fontWeight: FontWeight.bold, color: AppTheme.primaryText, height: 1.2)),
        const SizedBox(height: 16),
        Text('Registra tus emociones, encuentra claridad y cultiva tu bienestar día a día.', textAlign: TextAlign.center, style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyLarge, color: AppTheme.primaryText.withAlpha(180), height: 1.5)),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 1000.ms).slideY(begin: 0.3);
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4, shadowColor: AppTheme.primaryColor.withAlpha(100)),
          onPressed: () => context.pushNamed('auth'),
          child: Text('Empezar ahora', style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryText.withAlpha(200), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          onPressed: () => context.pushNamed('auth'),
          child: Text('Ya tengo una cuenta', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms, duration: 1000.ms).slideY(begin: 0.3);
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primaryColor..style = PaintingStyle.stroke..strokeWidth = 6.0..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.5, size.width * 0.5, size.height * 0.2);
    path.moveTo(size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.5, size.width * 0.5, size.height * 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}