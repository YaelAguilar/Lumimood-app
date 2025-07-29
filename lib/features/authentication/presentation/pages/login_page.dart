import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/loading_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == FormStatus.error) {
              final message = state.errorMessage ?? 'Ocurrió un error.';
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(message)),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
        ),
        BlocListener<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is AuthenticatedSessionState) {
              if (state.user.typeAccount == AccountType.specialist) {
                context.goNamed('specialist_dashboard');
              } else {
                context.goNamed('diary');
              }
            }
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AnimatedBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: const _LoginCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthCardContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
              DropdownButtonFormField<AccountType>(
                value: state.accountType,
                items: const [
                  DropdownMenuItem(
                    value: AccountType.patient,
                    child: Text('Paciente'),
                  ),
                  DropdownMenuItem(
                    value: AccountType.specialist,
                    child: Text('Especialista'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<AuthBloc>().add(AuthAccountTypeChanged(value));
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.account_circle_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuthFormField(
                initialValue: state.email,
                onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                hintText: 'Correo electrónico',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Ingresa un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthFormField(
                initialValue: state.password,
                onChanged: (password) => context.read<AuthBloc>().add(AuthPasswordChanged(password)),
                obscureText: !state.isPasswordVisible,
                prefixIcon: Icons.lock_outline,
                hintText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  if (value.length < 3) {
                    return 'La contraseña debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.goNamed('forgot_password'),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                onPressed: state.status == FormStatus.loading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed());
                        }
                      },
                isLoading: state.status == FormStatus.loading,
                text: state.accountType == AccountType.specialist ? "Iniciar como Especialista" : "Iniciar como Paciente",
              ),
              const SizedBox(height: 24),
              // Sección corregida para evitar overflow
              Column(
                children: [
                  Text(
                    '¿Aún no tienes una cuenta?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => context.goNamed('register'),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}