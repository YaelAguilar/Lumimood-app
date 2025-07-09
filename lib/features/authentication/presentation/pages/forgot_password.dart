import 'dart:ui';
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

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

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
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Se ha enviado un enlace de recuperación a tu correo.'),
              backgroundColor: AppTheme.primaryColor,
            ));
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryText, size: 30),
            onPressed: () => context.pop(),
          ),
        ),
        extendBodyBehindAppBar: true,
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
                    child: _ForgotPasswordCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Recuperar contraseña', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.displaySmall)),
            const SizedBox(height: 16),
            Text(
              'Ingresa el correo asociado a tu cuenta y te enviaremos un enlace para restablecer tu contraseña.',
              textAlign: TextAlign.center,
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: 24),
            TextFormField(
              onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return state.status == FormStatus.loading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        onPressed: () => context.read<AuthBloc>().add(AuthForgotPasswordRequested()),
                        text: 'Enviar enlace',
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
        ),
      ),
    ).animate().fade(duration: 400.ms).moveY(begin: 40);
  }
}