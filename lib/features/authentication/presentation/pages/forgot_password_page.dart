import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di.dart';
import '../../../../app/theme.dart';
import '../../../../common/widgets/custom_button.dart';
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryText, size: 30),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Atrás',
            style: GoogleFonts.interTight(textStyle: textTheme.titleLarge?.copyWith(fontSize: 18)),
          ),
          centerTitle: false,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 570),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olvidé mi contraseña', style: GoogleFonts.interTight(textStyle: textTheme.headlineMedium)),
                const SizedBox(height: 8),
                Text(
                  'Te enviaremos un correo con un enlace para resetear tu contraseña, por favor ingresa el correo asociado con tu cuenta.',
                  style: GoogleFonts.inter(textStyle: textTheme.labelMedium),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    hintText: 'Ingresa tu correo...',
                    contentPadding: EdgeInsets.all(24),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return state.status == FormStatus.loading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              onPressed: () => context.read<AuthBloc>().add(AuthForgotPasswordRequested()),
                              text: 'Enviar correo',
                              options: ButtonOptions(
                                width: 270,
                                height: 50,
                                color: AppTheme.primaryColor,
                                textStyle: GoogleFonts.interTight(
                                  textStyle: textTheme.titleSmall,
                                  color: Colors.white,
                                ),
                                elevation: 3,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}