import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/theme.dart';
import '../../../welcome/presentation/widgets/animated_background.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/account_type_selector.dart';
import '../widgets/auth_card_container.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/loading_button.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == FormStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
        if (state.status == FormStatus.success && state.successMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.successMessage!)),
                  ],
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.goNamed('login');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AnimatedBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: const _RegisterCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AuthCardContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crea tu cuenta',
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Empieza ingresando estos simples datos',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryText.withAlpha(179),
            ),
          ),
          const SizedBox(height: 24),
          const AccountTypeSelector(),
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
  final _patientBirthDateController = TextEditingController();
  final _specialistBirthDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _patientBirthDateController.dispose();
    _specialistBirthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectPatientDate(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: bloc.state.patientBirthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      bloc.add(AuthPatientBirthDateChanged(picked));
    }
  }

  Future<void> _selectSpecialistDate(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: bloc.state.specialistBirthDate ?? DateTime(1980),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      bloc.add(AuthSpecialistBirthDateChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => 
          previous.patientBirthDate != current.patientBirthDate ||
          previous.specialistBirthDate != current.specialistBirthDate,
      listener: (context, state) {
        if (state.patientBirthDate != null) {
          _patientBirthDateController.text = DateFormat.yMMMMd('es_ES').format(state.patientBirthDate!);
        } else {
          _patientBirthDateController.clear();
        }
        
        if (state.specialistBirthDate != null) {
          _specialistBirthDateController.text = DateFormat.yMMMMd('es_ES').format(state.specialistBirthDate!);
        } else {
          _specialistBirthDateController.clear();
        }
      },
      child: Form(
        key: _formKey,
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.accountType != c.accountType,
          builder: (context, state) {
            if (state.accountType == AccountType.patient) {
              return _buildPatientForm(context, state);
            } else {
              return _buildSpecialistForm(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPatientForm(BuildContext context, AuthState state) {
    return Column(
      children: [
        // ID del Profesional para pacientes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Necesitas el ID de tu especialista para registrarte. Solicítaselo directamente.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthProfessionalIdChanged(value)),
          prefixIcon: Icons.medical_services_outlined,
          hintText: 'ID del Especialista',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        
        // Campos personales del paciente
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthPatientNameChanged(value)),
          prefixIcon: Icons.person_outline,
          hintText: 'Nombre(s)',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AuthFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthPatientLastNameChanged(value)),
                hintText: 'Apellido paterno',
                keyboardType: TextInputType.name,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthPatientSecondLastNameChanged(value)),
                hintText: 'Apellido materno',
                keyboardType: TextInputType.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthEmailChanged(value)),
          prefixIcon: Icons.email_outlined,
          hintText: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AuthFormField(
                controller: _patientBirthDateController,
                readOnly: true,
                onTap: () => _selectPatientDate(context),
                prefixIcon: Icons.calendar_today_outlined,
                hintText: 'Nacimiento',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (p, c) => p.patientGender != c.patientGender,
                builder: (context, state) => DropdownButtonFormField<String>(
                  value: state.patientGender,
                  items: ['Masculino', 'Femenino', 'Otro']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<AuthBloc>().add(AuthPatientGenderChanged(value));
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Género',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthPatientPhoneNumberChanged(value)),
          prefixIcon: Icons.phone_outlined,
          hintText: 'Número de teléfono',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.isPasswordVisible != c.isPasswordVisible,
          builder: (context, state) => AuthFormField(
            onChanged: (value) => context.read<AuthBloc>().add(AuthPasswordChanged(value)),
            obscureText: !state.isPasswordVisible,
            prefixIcon: Icons.lock_outline,
            hintText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildRegisterButton(context, state),
        const SizedBox(height: 24),
        _buildLoginLink(context),
      ],
    );
  }

  Widget _buildSpecialistForm(BuildContext context, AuthState state) {
    return Column(
      children: [
        // Campos personales del especialista
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthSpecialistNameChanged(value)),
          prefixIcon: Icons.person_outline,
          hintText: 'Nombre(s)',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AuthFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthSpecialistLastNameChanged(value)),
                hintText: 'Apellido paterno',
                keyboardType: TextInputType.name,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthFormField(
                onChanged: (value) => context.read<AuthBloc>().add(AuthSpecialistSecondLastNameChanged(value)),
                hintText: 'Apellido materno',
                keyboardType: TextInputType.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthEmailChanged(value)),
          prefixIcon: Icons.email_outlined,
          hintText: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AuthFormField(
                controller: _specialistBirthDateController,
                readOnly: true,
                onTap: () => _selectSpecialistDate(context),
                prefixIcon: Icons.calendar_today_outlined,
                hintText: 'Nacimiento',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (p, c) => p.specialistGender != c.specialistGender,
                builder: (context, state) => DropdownButtonFormField<String>(
                  value: state.specialistGender,
                  items: ['Masculino', 'Femenino', 'Otro']
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<AuthBloc>().add(AuthSpecialistGenderChanged(value));
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Género',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthSpecialistPhoneNumberChanged(value)),
          prefixIcon: Icons.phone_outlined,
          hintText: 'Número de teléfono',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // Campos profesionales del especialista
        DropdownButtonFormField<String>(
          value: state.professionName,
          items: ['psicologo', 'psiquiatra']
              .map((label) => DropdownMenuItem(
                    value: label,
                    child: Text(label[0].toUpperCase() + label.substring(1)),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<AuthBloc>().add(AuthProfessionNameChanged(value));
            }
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.work_outline, color: AppTheme.primaryColor),
            hintText: 'Profesión',
          ),
        ),
        const SizedBox(height: 16),
        AuthFormField(
          onChanged: (value) => context.read<AuthBloc>().add(AuthProfessionalLicenseChanged(value)),
          prefixIcon: Icons.badge_outlined,
          hintText: 'Cédula Profesional',
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.isPasswordVisible != c.isPasswordVisible,
          builder: (context, state) => AuthFormField(
            onChanged: (value) => context.read<AuthBloc>().add(AuthPasswordChanged(value)),
            obscureText: !state.isPasswordVisible,
            prefixIcon: Icons.lock_outline,
            hintText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () => context.read<AuthBloc>().add(AuthPasswordVisibilityToggled()),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildRegisterButton(context, state),
        const SizedBox(height: 24),
        _buildLoginLink(context),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context, AuthState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        return LoadingButton(
          onPressed: state.status == FormStatus.loading
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<AuthBloc>().add(AuthRegisterWithEmailAndPasswordPressed());
                  }
                },
          isLoading: state.status == FormStatus.loading,
          text: 'Crear cuenta',
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Column(
      children: [
        Text(
          '¿Ya tienes una cuenta?',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.goNamed('login'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Inicia sesión',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}