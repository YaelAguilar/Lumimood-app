import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ya no creamos un nuevo BlocProvider aquí porque el AuthBloc
    // se proporciona desde el router
    return const _LoginView();
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == FormStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
              ),
            );
        }
        if (state.status == FormStatus.success) {
          final authState = context.read<AuthBloc>().state;
          if (authState.accountType == AccountType.specialist) {
            context.goNamed('specialist_home');
          } else {
            context.goNamed('diary');
          }
          // Resetea el estado después de la navegación
          context.read<AuthBloc>().add(AuthResetState());
        }
      },
      // El child del listener es directamente el Scaffold
      child: Scaffold(
        body: Stack(
          children: [
            const AnimatedBackground(),
            // --- CAMBIO CLAVE: Se eliminó el GestureDetector que envolvía el Center ---
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _LoginCard(),
              ),
            ),
          ],
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
      // ... (código del card sin cambios)
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
                child: Text('L', style: GoogleFonts.notoSans(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(textStyle: textTheme.headlineMedium, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tus credenciales para continuar',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppTheme.primaryText.withAlpha(179)),
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          children: [
            // Dropdown
            DropdownButtonFormField<AccountType>(
              value: state.accountType,
              items: const [
                DropdownMenuItem(value: AccountType.patient, child: Text('Paciente')),
                DropdownMenuItem(value: AccountType.specialist, child: Text('Especialista')),
              ],
              onChanged: (value) {
                if (value != null) context.read<AuthBloc>().add(AuthAccountTypeChanged(value));
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Email
            TextFormField(
              onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                hintText: 'Correo electrónico',
              ),
            ),
            const SizedBox(height: 16),
            // Password
            TextFormField(
              onChanged: (password) => context.read<AuthBloc>().add(AuthPasswordChanged(password)),
              obscureText: !state.isPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                hintText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.pushNamed('forgot_password'),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Botón de Login
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: state.status == FormStatus.loading
                    ? null
                    : () {
                        log('>>> LOGIN BUTTON TAPPED! Type: ${state.accountType.name}');
                        context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed());
                      },
                child: state.status == FormStatus.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Iniciar sesión como ${state.accountType == AccountType.specialist ? "Especialista" : "Paciente"}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Register Link
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, color: AppTheme.primaryText),
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
      },
    );
  }
}