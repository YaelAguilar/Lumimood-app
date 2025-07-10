import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
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
    return BlocListener<WelcomeBloc, WelcomeState>(
      listener: (context, state) {
        if (state is WelcomeNavigateToLogin) {
          context.pushNamed('login');
        } else if (state is WelcomeNavigateToRegister) {
          context.pushNamed('register');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0FBFD), Color(0xFFC4F2C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const SafeArea(
            child: _WelcomeContent(),
          ),
        ),
      ),
    );
  }
}

class _WelcomeContent extends StatefulWidget {
  const _WelcomeContent();

  @override
  State<_WelcomeContent> createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<_WelcomeContent> with WidgetsBindingObserver {
  bool _isLoading = false;
  String? _loadingAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resetLoadingState();
    }
  }

  void _resetLoadingState() {
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
        _loadingAction = null;
      });
    }
  }

  void _handleNavigation(String action) {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _loadingAction = action;
    });
    
    HapticFeedback.lightImpact();
    
    Future.delayed(const Duration(seconds: 3), () {
      _resetLoadingState();
    });
    
    if (action == 'login') {
      context.read<WelcomeBloc>().add(LoginButtonPressed());
    } else {
      context.read<WelcomeBloc>().add(RegisterButtonPressed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(flex: 2),
          
          _ModernLogo(),
          
          const SizedBox(height: 48),
          
          _WelcomeCard(),
          
          const Spacer(flex: 2),
          
          _ActionButtons(
            isLoading: _isLoading,
            loadingAction: _loadingAction,
            onLogin: () => _handleNavigation('login'),
            onRegister: () => _handleNavigation('register'),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ModernLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Hero(
      tag: 'logo_hero',
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha(51),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'L',
            style: GoogleFonts.notoSans(
              textStyle: textTheme.displayLarge,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    )
    .animate(onComplete: (controller) => controller.repeat(reverse: true))
    .scale(
      duration: 3000.ms,
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      curve: Curves.easeInOut,
    )
    .animate()
    .fadeIn(delay: 300.ms, duration: 600.ms)
    .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(179),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(153)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Bienvenido a Lumimood',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              textStyle: textTheme.headlineMedium,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu viaje hacia el bienestar emocional comienza aquí. Registra tus emociones y descubre patrones en tu estado de ánimo.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: textTheme.bodyLarge,
              color: AppTheme.primaryText.withAlpha(179),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3);
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isLoading;
  final String? loadingAction;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _ActionButtons({
    required this.isLoading,
    required this.loadingAction,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      children: [
        // Botón de Login
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withAlpha(204),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(51),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onLogin,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLoading && loadingAction == 'login'
                      ? const SizedBox(
                          key: ValueKey('login_loader'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          key: const ValueKey('login_text'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.login, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Iniciar sesión',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.3),
        
        const SizedBox(height: 16),
        
        // Botón de Registro
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(179),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onRegister,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLoading && loadingAction == 'register'
                      ? SizedBox(
                          key: const ValueKey('register_loader'),
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : Row(
                          key: const ValueKey('register_text'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Crear cuenta nueva',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }
}