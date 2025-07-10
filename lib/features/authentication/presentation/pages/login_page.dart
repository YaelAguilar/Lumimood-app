import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == FormStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage ?? 'Ocurrió un error inesperado.')),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
        if (state.status == FormStatus.success) {
          context.goNamed('diary');
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Stack(
            children: [
              const AnimatedBackground(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _LoginCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _LoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'logo_hero',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'L',
                  style: GoogleFonts.notoSans(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              textStyle: textTheme.headlineMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tus credenciales para continuar',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryText.withAlpha(179),
            ),
          ),
          const SizedBox(height: 32),
          const _LoginForm(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1);
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      children: [
        TextFormField(
          onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
            hintText: 'Correo electrónico',
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => previous.isPasswordVisible != current.isPasswordVisible,
          builder: (context, state) {
            return TextFormField(
              onChanged: (password) => context.read<AuthBloc>().add(AuthPasswordChanged(password)),
              obscureText: !state.isPasswordVisible,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                hintText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.pushNamed('forgot_password'),
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (context, state) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                shadowColor: AppTheme.primaryColor.withAlpha(100),
              ),
              onPressed: state.status == FormStatus.loading 
                ? null 
                : () => context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed()),
              child: state.status == FormStatus.loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Iniciar sesión', style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          },
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(textStyle: textTheme.bodyMedium, color: AppTheme.primaryText),
            children: [
              const TextSpan(text: '¿Aún no tienes una cuenta? '),
              TextSpan(
                text: 'Regístrate',
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()..onTap = () => context.pushNamed('register'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}