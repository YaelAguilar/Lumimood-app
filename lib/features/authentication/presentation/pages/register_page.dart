import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/custom_button.dart';
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
    final textTheme = Theme.of(context).textTheme;

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
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0FBFD), Color(0xFF89EA81)],
                stops: [0, 1],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 570),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x33000000), offset: Offset(0, 2))],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Regístrate', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.displaySmall)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                          child: Text('Empieza ingresando estos simples datos', textAlign: TextAlign.center, style: GoogleFonts.inter(textStyle: textTheme.labelLarge)),
                        ),
                        const _RegisterForm(),
                      ],
                    ),
                  ),
                ).animate()
                   .fade(duration: 300.ms)
                   .moveY(begin: 140)
                   .scale(begin: const Offset(0.9, 0.9))
                   .rotate(begin: -0.06, duration: 300.ms, curve: Curves.easeInOut),
              ),
            ),
          ),
        ),
      ),
    );
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
        TextFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthLastNameChanged(value)),
          decoration: const InputDecoration(labelText: 'Apellido paterno'),
          keyboardType: TextInputType.name,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
        ),
        const SizedBox(height: 16),
        TextFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthSecondLastNameChanged(value)),
          decoration: const InputDecoration(labelText: 'Apellido materno'),
          keyboardType: TextInputType.name,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
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
                decoration: const InputDecoration(hintText: 'Sexo'),
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
                    text: 'Registrar',
                    options: ButtonOptions(
                      width: double.infinity,
                      height: 44,
                      color: AppTheme.primaryColor,
                      textStyle: GoogleFonts.interTight(textStyle: textTheme.titleSmall, color: Colors.white),
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
          },
        ),
        const SizedBox(height: 24),
        Text('O regístrate con', textAlign: TextAlign.center, style: textTheme.labelLarge),
        const SizedBox(height: 16),
        CustomButton(
          onPressed: () => context.read<AuthBloc>().add(AuthLoginWithGooglePressed()),
          text: 'Continuar con Google',
          icon: const FaIcon(FontAwesomeIcons.google, size: 20),
          options: ButtonOptions(
            width: double.infinity,
            height: 44,
            color: Theme.of(context).scaffoldBackgroundColor,
            textStyle: GoogleFonts.interTight(textStyle: textTheme.titleSmall, color: AppTheme.primaryText),
            elevation: 0,
            borderSide: BorderSide(color: AppTheme.alternate, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}