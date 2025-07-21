import 'package:flutter/cupertino.dart'; // Necesario para el CupertinoSlidingSegmentedControl
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/theme.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthenticationView();
  }
}

class _AuthenticationView extends StatelessWidget {
  const _AuthenticationView();

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
                    content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message))]),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
            if (state.status == FormStatus.success && (state.viewMode == AuthViewMode.register || state.viewMode == AuthViewMode.forgotPassword)) {
              final message = state.successMessage ?? 'Operación exitosa.';
               ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message))]),
                    backgroundColor: AppTheme.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              context.read<AuthBloc>().add(AuthViewModeChanged(AuthViewMode.login));
            }
          },
        ),
        BlocListener<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is AuthenticatedSessionState) {
              if (state.user.typeAccount == AccountType.specialist) {
                context.goNamed('specialist_home');
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
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.vertical,
                            axisAlignment: -1.0,
                            child: child,
                          ),
                        );
                      },
                      child: _getAuthCard(state.viewMode),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAuthCard(AuthViewMode viewMode) {
    switch (viewMode) {
      case AuthViewMode.login:
        return const _LoginCard(key: ValueKey('login'));
      case AuthViewMode.register:
        return const _RegisterCard(key: ValueKey('register'));
      case AuthViewMode.forgotPassword:
        return const _ForgotPasswordCard(key: ValueKey('forgot_password'));
    }
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bienvenido de nuevo', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.displayLarge, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Ingresa tus credenciales para continuar', textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: AppTheme.primaryText.withAlpha(179))),
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
                items: const [DropdownMenuItem(value: AccountType.patient, child: Text('Paciente')), DropdownMenuItem(value: AccountType.specialist, child: Text('Especialista'))],
                onChanged: (value) { if (value != null) { context.read<AuthBloc>().add(AuthAccountTypeChanged(value)); } },
                decoration: InputDecoration(prefixIcon: const Icon(Icons.account_circle_outlined, color: AppTheme.primaryColor), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: state.email,
                onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) { if (value == null || value.trim().isEmpty) { return 'El email es requerido'; } if (!value.contains('@')) { return 'Ingresa un email válido'; } return null; },
                decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor), hintText: 'Correo electrónico'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: state.password,
                onChanged: (password) => context.read<AuthBloc>().add(AuthPasswordChanged(password)),
                obscureText: !state.isPasswordVisible,
                validator: (value) { if (value == null || value.trim().isEmpty) { return 'La contraseña es requerida'; } if (value.length < 3) { return 'La contraseña debe tener al menos 3 caracteres'; } return null; },
                decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor), hintText: 'Contraseña', suffixIcon: IconButton(icon: Icon(state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()))),
              ),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.read<AuthBloc>().add(AuthViewModeChanged(AuthViewMode.forgotPassword)), child: Text('¿Olvidaste tu contraseña?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), disabledBackgroundColor: Colors.grey.shade400, elevation: 0, shadowColor: Colors.transparent),
                  onPressed: state.status == FormStatus.loading ? null : () { if (_formKey.currentState?.validate() ?? false) { context.read<AuthBloc>().add(AuthLoginWithEmailAndPasswordPressed()); } },
                  child: state.status == FormStatus.loading ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), const SizedBox(width: 12), Text('Iniciando sesión...', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))]) : Text('Iniciar sesión como ${state.accountType == AccountType.specialist ? "Especialista" : "Paciente"}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              RichText(text: TextSpan(style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, color: AppTheme.primaryText), children: [const TextSpan(text: '¿Aún no tienes una cuenta? '), TextSpan(text: 'Regístrate', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold), recognizer: TapGestureRecognizer()..onTap = () => context.read<AuthBloc>().add(AuthViewModeChanged(AuthViewMode.register)))])),
            ],
          );
        },
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Crea tu cuenta', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.displayLarge, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Empieza ingresando estos simples datos', textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: AppTheme.primaryText.withAlpha(179))),
          const SizedBox(height: 24),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.accountType != c.accountType,
            builder: (context, state) {
              return CupertinoSlidingSegmentedControl<AccountType>(
                backgroundColor: AppTheme.alternate,
                thumbColor: AppTheme.primaryColor,
                groupValue: state.accountType,
                children: const {
                  AccountType.patient: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Soy Paciente', style: TextStyle(color: Colors.white))),
                  AccountType.specialist: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Soy Especialista', style: TextStyle(color: Colors.white))),
                },
                onValueChanged: (value) {
                  if (value != null) {
                    context.read<AuthBloc>().add(AuthAccountTypeChanged(value));
                  }
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const _RegisterForm(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1);
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _birthDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final DateTime? picked = await showDatePicker(context: context, initialDate: bloc.state.birthDate ?? DateTime(2000), firstDate: DateTime(1920), lastDate: DateTime.now(), locale: const Locale('es', 'ES'));
    if (picked != null) {
      bloc.add(AuthBirthDateChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.birthDate != current.birthDate,
      listener: (context, state) {
        if (state.birthDate != null) {
          _birthDateController.text = DateFormat.yMMMMd('es_ES').format(state.birthDate!);
        } else {
          _birthDateController.clear();
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(onChanged: (value) => context.read<AuthBloc>().add(AuthNameChanged(value)), decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor), hintText: 'Nombre(s)'), keyboardType: TextInputType.name),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: TextFormField(onChanged: (value) => context.read<AuthBloc>().add(AuthLastNameChanged(value)), decoration: const InputDecoration(hintText: 'Apellido paterno'), keyboardType: TextInputType.name)), const SizedBox(width: 16), Expanded(child: TextFormField(onChanged: (value) => context.read<AuthBloc>().add(AuthSecondLastNameChanged(value)), decoration: const InputDecoration(hintText: 'Apellido materno'), keyboardType: TextInputType.name))]),
            const SizedBox(height: 16),
            TextFormField(onChanged: (value) => context.read<AuthBloc>().add(AuthEmailChanged(value)), decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor), hintText: 'Correo electrónico'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: TextFormField(controller: _birthDateController, readOnly: true, onTap: () => _selectDate(context), decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor), hintText: 'Nacimiento'))), const SizedBox(width: 16), Expanded(child: BlocBuilder<AuthBloc, AuthState>(buildWhen: (p, c) => p.gender != c.gender, builder: (context, state) => DropdownButtonFormField<String>(value: state.gender, items: ['Masculino', 'Femenino', 'Otro'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(), onChanged: (value) { if (value != null) { context.read<AuthBloc>().add(AuthGenderChanged(value)); } }, decoration: const InputDecoration(hintText: 'Género', contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0)))))]),
            const SizedBox(height: 16),
            TextFormField(onChanged: (value) => context.read<AuthBloc>().add(AuthPhoneNumberChanged(value)), decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor), hintText: 'Número de teléfono'), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (p, c) => p.accountType != c.accountType,
              builder: (context, state) {
                if (state.accountType == AccountType.specialist) {
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: state.professionName,
                        items: ['psicologo', 'psiquiatra'].map((label) => DropdownMenuItem(value: label, child: Text(label[0].toUpperCase() + label.substring(1)))).toList(),
                        onChanged: (value) { if (value != null) { context.read<AuthBloc>().add(AuthProfessionNameChanged(value)); } },
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.work_outline, color: AppTheme.primaryColor), hintText: 'Profesión'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        onChanged: (value) => context.read<AuthBloc>().add(AuthProfessionalLicenseChanged(value)),
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryColor), hintText: 'Cédula Profesional'),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ).animate().fadeIn(duration: 400.ms);
                }
                return const SizedBox.shrink();
              },
            ),
            BlocBuilder<AuthBloc, AuthState>(buildWhen: (p, c) => p.isPasswordVisible != c.isPasswordVisible, builder: (context, state) => TextFormField(onChanged: (value) => context.read<AuthBloc>().add(AuthPasswordChanged(value)), obscureText: !state.isPasswordVisible, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor), hintText: 'Contraseña', suffixIcon: IconButton(icon: Icon(state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey.shade600), onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()))))),
            const SizedBox(height: 32),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (p, c) => p.status != c.status,
              builder: (context, state) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, shadowColor: Colors.transparent),
                  onPressed: state.status == FormStatus.loading ? null : () { if (_formKey.currentState?.validate() ?? false) { context.read<AuthBloc>().add(AuthRegisterWithEmailAndPasswordPressed()); } },
                  child: state.status == FormStatus.loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear cuenta')
                );
              },
            ),
            const SizedBox(height: 24),
            RichText(textAlign: TextAlign.center, text: TextSpan(style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.bodyMedium, color: AppTheme.primaryText), children: [const TextSpan(text: '¿Ya tienes una cuenta? '), TextSpan(text: 'Inicia sesión', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold), recognizer: TapGestureRecognizer()..onTap = () => context.read<AuthBloc>().add(AuthViewModeChanged(AuthViewMode.login)))])),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(26), shape: BoxShape.circle), child: const Icon(Icons.lock_reset, size: 40, color: AppTheme.primaryColor)),
          const SizedBox(height: 24),
          Text('Recuperar contraseña', textAlign: TextAlign.center, style: GoogleFonts.interTight(textStyle: textTheme.headlineMedium, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Ingresa el correo asociado a tu cuenta y te enviaremos las instrucciones.', textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: AppTheme.primaryText.withAlpha(179), height: 1.5)),
          const SizedBox(height: 32),
          TextFormField(onChanged: (email) => context.read<AuthBloc>().add(AuthEmailChanged(email)), decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor), hintText: 'Correo electrónico'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 32),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, shadowColor: Colors.transparent),
                onPressed: state.status == FormStatus.loading ? null : () => context.read<AuthBloc>().add(AuthForgotPasswordRequested()),
                child: state.status == FormStatus.loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Enviar enlace'),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1);
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white.withAlpha(217),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 30, offset: const Offset(0, 10))],
    border: Border.all(color: Colors.white.withAlpha(51), width: 1.5),
  );
}