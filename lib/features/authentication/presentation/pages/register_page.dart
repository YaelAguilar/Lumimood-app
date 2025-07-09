import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == FormStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(state.errorMessage ?? 'Ocurrió un error'),
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
                      child: _RegisterFormCard(),
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

class _RegisterFormCard extends StatelessWidget {
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
              child: Text('Crea tu cuenta', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.displaySmall)),
            ),
            Text('Empieza ingresando estos simples datos', textAlign: TextAlign.center, style: textTheme.labelLarge),
            const SizedBox(height: 24),
            const _RegisterForm(),
            const SizedBox(height: 24),
            const _LoginLink(),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).moveY(begin: 40);
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        TextFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthNameChanged(value)),
          decoration: const InputDecoration(labelText: 'Nombre(s)'),
          keyboardType: TextInputType.name,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthLastNameChanged(value)),
                decoration: const InputDecoration(labelText: 'Apellido paterno'),
                keyboardType: TextInputType.name,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthSecondLastNameChanged(value)),
                decoration: const InputDecoration(labelText: 'Apellido materno'),
                keyboardType: TextInputType.name,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthEmailChanged(value)),
          decoration: const InputDecoration(labelText: 'Correo'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.isPasswordVisible != c.isPasswordVisible,
          builder: (context, state) {
            return TextFormField(
              onChanged: (value) => context.read<AuthBloc>().add(AuthPasswordChanged(value)),
              obscureText: !state.isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.gender != c.gender,
            builder: (context, state) {
            return DropdownButtonFormField<String>(
                value: state.gender,
                items: ['Hombre', 'Mujer', 'Prefiero no decir', 'Otro']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                if (value != null) {
                    context.read<AuthBloc>().add(AuthGenderChanged(value));
                }
                },
                decoration: const InputDecoration(labelText: 'Género'),
            );
        }),
        const SizedBox(height: 24),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (context, state) {
            return state.status == FormStatus.loading
                ? const CircularProgressIndicator()
                : CustomButton(
                    onPressed: () => context.read<AuthBloc>().add(AuthRegisterWithEmailAndPasswordPressed()),
                    text: 'Crear cuenta',
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
        ),
      ],
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium),
        children: [
          const TextSpan(text: '¿Ya tienes una cuenta? '),
          TextSpan(
            text: 'Inicia sesión',
            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () => context.goNamed('login'),
          ),
        ],
      ),
    );
  }
}