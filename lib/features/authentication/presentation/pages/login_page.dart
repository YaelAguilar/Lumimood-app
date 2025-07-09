import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/custom_button.dart';
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
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Ocurrió un error inesperado.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
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
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withAlpha(26),
                  child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _LoginFormCard(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 570),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(217),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'logo_hero',
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.alternate,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('L', style: GoogleFonts.notoSans(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text('Bienvenido de nuevo', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.displaySmall)),
            ),
            Text('Ingresa tus credenciales para continuar', textAlign: TextAlign.center, style: textTheme.labelLarge),
            const SizedBox(height: 24),
            const _EmailInputField(),
            const SizedBox(height: 16),
            const _PasswordInputField(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.pushNamed('forgot_password'),
                child: Text('¿Olvidaste tu contraseña?', style: textTheme.bodyMedium?.override(color: AppTheme.primaryText.withAlpha(179))),
              ),
            ),
            const SizedBox(height: 16),
            const _LoginButton(),
            const SizedBox(height: 24),
            const _RegisterLink(),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).moveY(begin: 40);
  }
}

class _EmailInputField extends StatelessWidget {
  const _EmailInputField();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(labelText: 'Correo'),
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.isPasswordVisible != current.isPasswordVisible,
      builder: (context, state) {
        return TextFormField(
          onChanged: (password) => context.read<AuthBloc>().add(AuthPasswordChanged(password)),
          obscureText: !state.isPasswordVisible,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            labelText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
              onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final textTheme = Theme.of(context).textTheme;
        return state.status == FormStatus.loading
            ? const SizedBox(height: 52, child: Center(child: CircularProgressIndicator()))
            : CustomButton(
                onPressed: () => context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed()),
                text: 'Iniciar sesión',
                options: ButtonOptions(
                  width: double.infinity,
                  height: 52,
                  color: AppTheme.primaryColor,
                  textStyle: GoogleFonts.interTight(textStyle: textTheme.titleSmall, color: Colors.white),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
      },
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium),
        children: [
          const TextSpan(text: '¿Aún no tienes una cuenta? '),
          TextSpan(
            text: 'Regístrate',
            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () => context.pushNamed('register'),
          ),
        ],
      ),
    );
  }
}