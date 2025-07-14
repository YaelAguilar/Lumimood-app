import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginView();
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener para errores del AuthBloc
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => 
            previous.status != current.status && current.status == FormStatus.error,
          listener: (context, state) {
            log('🔴 LOGIN: Error state detected - ${state.errorMessage}');
            if (state.errorMessage != null) {
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
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
        ),
        // Listener para éxito del AuthBloc
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => 
            previous.status != current.status && current.status == FormStatus.success,
          listener: (context, state) {
            log('🟢 LOGIN: Success state detected');
            // Navegación inmediata sin delay async
            _handleSuccessfulLogin(context);
          },
        ),
      ],
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
    );
  }

  void _handleSuccessfulLogin(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    log('📱 LOGIN: Current session state: ${sessionState.runtimeType}');
    
    if (sessionState is AuthenticatedSessionState) {
      log('✅ LOGIN: Session authenticated, navigating...');
      if (sessionState.user.typeAccount == AccountType.specialist) {
        log('🏥 LOGIN: Navigating to specialist home');
        context.goNamed('specialist_home');
      } else {
        log('📖 LOGIN: Navigating to diary');
        context.goNamed('diary');
      }
      // Reset del estado después de navegar
      context.read<AuthBloc>().add(AuthResetState());
    } else {
      log('❌ LOGIN: Session not authenticated after success');
      // Intentar nuevamente después de un frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final newSessionState = context.read<SessionCubit>().state;
          if (newSessionState is AuthenticatedSessionState) {
            if (newSessionState.user.typeAccount == AccountType.specialist) {
              context.goNamed('specialist_home');
            } else {
              context.goNamed('diary');
            }
            context.read<AuthBloc>().add(AuthResetState());
          }
        }
      });
    }
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

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Column(
            children: [
              // Dropdown para tipo de cuenta
              DropdownButtonFormField<AccountType>(
                value: state.accountType,
                items: const [
                  DropdownMenuItem(value: AccountType.patient, child: Text('Paciente')),
                  DropdownMenuItem(value: AccountType.specialist, child: Text('Especialista')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<AuthBloc>().add(AuthAccountTypeChanged(value));
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              // Campo Email
              TextFormField(
                onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                  hintText: 'Correo electrónico',
                ),
              ),
              const SizedBox(height: 16),
              // Campo Password
              TextFormField(
                onChanged: (password) => context.read<AuthBloc>().add(AuthPasswordChanged(password)),
                obscureText: !state.isPasswordVisible,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  if (value.length < 3) {
                    return 'La contraseña debe tener al menos 3 caracteres';
                  }
                  return null;
                },
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
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  onPressed: state.status == FormStatus.loading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            log('🚀 LOGIN: Form validated, attempting login');
                            log('📧 LOGIN: Email: ${state.email}');
                            log('👤 LOGIN: Account type: ${state.accountType.name}');
                            context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed());
                          } else {
                            log('❌ LOGIN: Form validation failed');
                          }
                        },
                  child: state.status == FormStatus.loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Iniciando sesión...',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
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
      ),
    );
  }
}