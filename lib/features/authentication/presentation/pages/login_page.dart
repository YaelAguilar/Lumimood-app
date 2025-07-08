import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/custom_button.dart';
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                const _Header(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      const _EmailInputField(),
                      const SizedBox(height: 16),
                      const _PasswordInputField(),
                      const SizedBox(height: 16),
                      const _LoginButtons(),
                      const SizedBox(height: 24),
                      const _SocialLogin(),
                      const SizedBox(height: 24),
                      const _RegisterLink(),
                    ],
                  ).animate().fade(delay: 200.ms, duration: 400.ms).moveY(begin: 60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF39E2EF), Color(0xFF63DA5C), Color(0xFF60EEB4)],
          stops: [0, 0.5, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Theme.of(context).scaffoldBackgroundColor],
            stops: const [0, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha(204),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.animation, color: AppTheme.primaryColor, size: 44),
            ).animate().fade(duration: 300.ms).scale(begin: const Offset(0.6, 0.6), curve: Curves.bounceOut),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Inicia sesión', style: GoogleFonts.interTight(textStyle: textTheme.headlineSmall)),
            ).animate().fade(delay: 100.ms, duration: 400.ms).moveY(begin: 30),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Introduce tus datos para iniciar sesión', style: GoogleFonts.inter(textStyle: textTheme.labelMedium)),
            ).animate().fade(delay: 150.ms, duration: 400.ms).moveY(begin: 30),
          ],
        ),
      ),
    );
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
      decoration: const InputDecoration(labelText: 'Correo', contentPadding: EdgeInsets.all(24)),
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
            contentPadding: const EdgeInsets.all(24),
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

class _LoginButtons extends StatelessWidget {
  const _LoginButtons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final textTheme = Theme.of(context).textTheme;
        return Column(
          children: [
            if (state.status == FormStatus.loading)
              const SizedBox(height: 52, child: Center(child: CircularProgressIndicator()))
            else
              CustomButton(
                onPressed: () => context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed()),
                text: 'Iniciar sesión',
                options: ButtonOptions(
                  width: 230,
                  height: 52,
                  color: AppTheme.primaryColor,
                  textStyle: GoogleFonts.interTight(textStyle: textTheme.titleSmall, color: Colors.white),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            TextButton(
              onPressed: () => context.pushNamed('forgot_password'),
              child: Text('Olvidé mi contraseña', style: GoogleFonts.inter(textStyle: textTheme.bodyMedium)),
            ),
          ],
        );
      },
    );
  }
}

class _SocialLogin extends StatelessWidget {
  const _SocialLogin();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('O inicia sesión con', textAlign: TextAlign.center, style: GoogleFonts.inter(textStyle: textTheme.labelMedium)),
        const SizedBox(height: 16),
        CustomButton(
          onPressed: () => context.read<AuthBloc>().add(AuthLoginWithGooglePressed()),
          text: 'Continuar con Google',
          icon: const FaIcon(FontAwesomeIcons.google, size: 20),
          options: ButtonOptions(
            width: 230,
            height: 44,
            color: Theme.of(context).scaffoldBackgroundColor,
            textStyle: GoogleFonts.inter(textStyle: textTheme.bodyMedium, fontWeight: FontWeight.bold),
            borderSide: BorderSide(color: AppTheme.alternate, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium),
          children: [
            const TextSpan(text: '¿Aún no tienes una cuenta? '),
            TextSpan(
              text: ' Regístrate',
              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()..onTap = () => context.pushNamed('register'),
            ),
          ],
        ),
      ),
    );
  }
}