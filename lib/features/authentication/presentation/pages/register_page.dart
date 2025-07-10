import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/injection_container.dart';
import '../../../../core/presentation/theme.dart';
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
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(state.errorMessage ?? 'Ocurrió un error'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
        if (state.status == FormStatus.success) {
          context.goNamed('diary');
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0FBFD), Color(0xFFC4F2C2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(179),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(102)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.primaryText),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed('welcome');
                          }
                        },
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _RegisterCard(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
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
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                child: Text(
                  'L',
                  style: GoogleFonts.notoSans(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Crea tu cuenta',
            textAlign: TextAlign.center,
            style: GoogleFonts.interTight(
              textStyle: textTheme.headlineMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Empieza ingresando estos simples datos',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryText.withAlpha(179),
            ),
          ),
          
          const SizedBox(height: 32),
          
          const _RegisterForm(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3);
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextFormField(
            onChanged: (value) => context.read<AuthBloc>().add(AuthNameChanged(value)),
            decoration: const InputDecoration(
              labelText: 'Nombre(s)',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.person_outline,
                color: AppTheme.primaryColor,
              ),
            ),
            keyboardType: TextInputType.name,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextFormField(
                  onChanged: (value) => context.read<AuthBloc>().add(AuthLastNameChanged(value)),
                  decoration: const InputDecoration(
                    labelText: 'Apellido paterno',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.name,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextFormField(
                  onChanged: (value) => context.read<AuthBloc>().add(AuthSecondLastNameChanged(value)),
                  decoration: const InputDecoration(
                    labelText: 'Apellido materno',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.name,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextFormField(
            onChanged: (value) => context.read<AuthBloc>().add(AuthEmailChanged(value)),
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        
        const SizedBox(height: 16),
        
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.isPasswordVisible != c.isPasswordVisible,
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthPasswordChanged(value)),
                obscureText: !state.isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.gender != c.gender,
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonFormField<String>(
                value: state.gender,
                items: ['Hombre', 'Mujer', 'Prefiero no decir', 'Otro']
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<AuthBloc>().add(AuthGenderChanged(value));
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Género',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.wc_outlined,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (context, state) {
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withAlpha(204),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(51),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: state.status == FormStatus.loading 
                      ? null 
                      : () => context.read<AuthBloc>().add(AuthRegisterWithEmailAndPasswordPressed()),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: state.status == FormStatus.loading
                          ? const SizedBox(
                              key: ValueKey('loader'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              key: const ValueKey('text'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_add, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Crear cuenta',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(textStyle: textTheme.bodyMedium),
            children: [
              const TextSpan(text: '¿Ya tienes una cuenta? '),
              TextSpan(
                text: 'Inicia sesión',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => context.goNamed('login'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}