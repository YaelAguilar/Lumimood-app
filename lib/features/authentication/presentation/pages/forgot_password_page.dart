import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/loading_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == FormStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
        if (state.status == FormStatus.success && state.successMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.successMessage!)),
                  ],
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.goNamed('login');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AnimatedBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: const _ForgotPasswordCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthCardContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recuperar contraseña',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Ingresa el correo asociado a tu cuenta y te enviaremos las instrucciones.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryText.withAlpha(179),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          AuthFormField(
            onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
            prefixIcon: Icons.email_outlined,
            hintText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return LoadingButton(
                onPressed: state.status == FormStatus.loading
                    ? null
                    : () => context.read<AuthBloc>().add(AuthForgotPasswordRequested()),
                isLoading: state.status == FormStatus.loading,
                text: 'Enviar enlace',
              );
            },
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.goNamed('login'),
            child: const Text(
              'Volver al inicio de sesión',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1);
  }
}