import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/custom_button.dart';
import '../bloc/welcome_bloc.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocListener<WelcomeBloc, WelcomeState>(
      listener: (context, state) {
        if (state is WelcomeNavigateToRegister) {
          context.pushNamed('register');
        } else if (state is WelcomeNavigateToLogin) {
          context.pushNamed('login');
        }
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF39E2EF), Color(0xFF63FF59), Color(0xFF60EE9E)],
                    stops: [0, 0.5, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, theme.scaffoldBackgroundColor],
                      stops: const [0, 1],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withAlpha(204),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('L', style: GoogleFonts.notoSans(textStyle: textTheme.displayLarge, color: AppTheme.primaryColor)),
                        ),
                      ).animate().fade(duration: 300.ms, delay: 300.ms).scale(begin: const Offset(0.6, 0.6), curve: Curves.bounceOut),
                      Padding(
                        padding: const EdgeInsets.only(top: 44),
                        child: Text('Bienvenido', style: GoogleFonts.interTight(textStyle: textTheme.displaySmall)),
                      ).animate().fade(duration: 400.ms, delay: 350.ms).moveY(begin: 30, end: 0, curve: Curves.easeInOut),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(44, 8, 44, 0),
                        child: Text(
                          'Gracias por unirte a Lumimood\nAccede o crea tu cuenta, y empieza con este viaje',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(textStyle: textTheme.labelMedium),
                        ),
                      ).animate().fade(duration: 400.ms, delay: 400.ms).moveY(begin: 30, end: 0, curve: Curves.easeInOut),
                    ],
                  ),
                ),
              ).animate().fade(duration: 400.ms).scale(begin: const Offset(3.0, 3.0)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 44),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () => context.read<WelcomeBloc>().add(RegisterButtonPressed()),
                      text: 'Regístrate',
                      options: ButtonOptions(
                        height: 52,
                        color: theme.colorScheme.surface,
                        textStyle: GoogleFonts.interTight(textStyle: textTheme.titleSmall, color: AppTheme.primaryText),
                        elevation: 3,
                        borderSide: BorderSide(color: AppTheme.alternate, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      onPressed: () => context.read<WelcomeBloc>().add(LoginButtonPressed()),
                      text: 'Iniciar sesión',
                      options: ButtonOptions(
                        height: 52,
                        color: AppTheme.primaryColor,
                        textStyle: GoogleFonts.interTight(textStyle: textTheme.titleSmall, color: Colors.white),
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ).animate().fade(duration: 600.ms, delay: 300.ms).scale(begin: const Offset(0.6, 0.6), curve: Curves.bounceOut),
            ),
          ],
        ),
      ),
    );
  }
}