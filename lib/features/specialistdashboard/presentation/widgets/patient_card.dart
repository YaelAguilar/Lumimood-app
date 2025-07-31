import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import '../../../../core/presentation/theme.dart';
import '../../../patients/domain/entities/patient_entity.dart';
import '../pages/patient_notes_page.dart';
import '../pages/patient_tasks_page.dart';
import '../pages/patient_observations_page.dart';

class PatientCard extends StatelessWidget {
  final PatientEntity patient;

  const PatientCard({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final age = _calculateAge(patient.birthDate);
    final cleanEmail = _cleanEmailText(patient.email);
    final cleanGender = _cleanGenderText(patient.gender);
    
    // Debug logs
    log('📱 PATIENT CARD: Building card for ${patient.fullName}');
    log('📱 PATIENT CARD: Raw email: "${patient.email}"');
    log('📱 PATIENT CARD: Clean email: "$cleanEmail"');
    log('📱 PATIENT CARD: Raw gender: "${patient.gender}"');
    log('📱 PATIENT CARD: Clean gender: "$cleanGender"');
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showPatientActions(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER ROW - Información básica
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      patient.name.isNotEmpty 
                          ? patient.name.substring(0, 1).toUpperCase()
                          : 'P',
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Información principal - CON FLEX PARA EVITAR OVERFLOW
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre completo - CONTROLADO PARA NO DESBORDAR
                      Text(
                        patient.fullName,
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleMedium,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Edad y género - FLEX PARA MANEJAR OVERFLOW
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$age años • $cleanGender',
                              style: GoogleFonts.inter(
                                textStyle: textTheme.bodySmall,
                                color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status badge - SIEMPRE AL FINAL
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Activo',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // EMAIL SECTION - MEJORADA PARA MOSTRAR CORRECTAMENTE
            _buildInfoRow(
              icon: Icons.email_outlined,
              content: cleanEmail.isNotEmpty ? cleanEmail : 'Email no disponible',
              isPlaceholder: cleanEmail.isEmpty,
              context: context,
            ),
            const SizedBox(height: 8),
            
            // TELÉFONO SECTION
            _buildInfoRow(
              icon: Icons.phone_outlined,
              content: patient.phone.isNotEmpty ? patient.phone : 'Teléfono no disponible',
              isPlaceholder: patient.phone.isEmpty,
              context: context,
            ),
            const SizedBox(height: 12),
            
            // BOTÓN DE ACCIÓN MEJORADO
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showPatientActions(context);
                  },
                  icon: const Icon(Icons.more_vert, size: 18),
                  label: const Text('Ver opciones'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget helper para crear filas de información sin overflow
  Widget _buildInfoRow({
    required IconData icon,
    required String content,
    required bool isPlaceholder,
    required BuildContext context,
  }) {
    final textTheme = Theme.of(context).textTheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: textTheme.bodyMedium?.copyWith(
                color: isPlaceholder 
                  ? Colors.grey.shade500
                  : AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _cleanGenderText(String gender) {
    if (gender.isEmpty || gender == 'null') return 'No especificado';
    
    // Limpiar formato {value: Masculino}
    if (gender.startsWith('{value:') || gender.startsWith('{value :')) {
      final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(gender);
      if (match != null) {
        gender = match.group(1)?.trim() ?? gender;
      }
    }
    // Limpiar comillas
    return gender.replaceAll('"', '').replaceAll("'", '').trim();
  }

  String _cleanEmailText(String email) {
    if (email.isEmpty || email == 'null') return '';
    
    log('📧 CLEANING EMAIL: Input: "$email"');
    
    // Limpiar formato {value: email@domain.com}
    if (email.startsWith('{value:') || email.startsWith('{value :')) {
      final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(email);
      if (match != null) {
        email = match.group(1)?.trim() ?? email;
        log('📧 CLEANING EMAIL: After removing {value:}: "$email"');
      }
    }
    
    // Limpiar comillas y espacios
    email = email.replaceAll('"', '').replaceAll("'", '').trim();
    log('📧 CLEANING EMAIL: After removing quotes: "$email"');
    
    // Validar que sea un email válido básico
    if (email.contains('@') && email.contains('.') && email.length > 5) {
      // Validación más estricta con regex
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (emailRegex.hasMatch(email)) {
        log('📧 CLEANING EMAIL: Valid email found: "$email"');
        return email;
      } else {
        log('📧 CLEANING EMAIL: Invalid email format: "$email"');
      }
    } else {
      log('📧 CLEANING EMAIL: Basic validation failed for: "$email"');
    }
    
    return '';
  }

void _showPatientActions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle para cerrar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header del modal
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      patient.name.isNotEmpty 
                          ? patient.name.substring(0, 1).toUpperCase()
                          : 'P',
                      style: GoogleFonts.interTight(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: GoogleFonts.interTight(
                          textStyle: Theme.of(context).textTheme.headlineSmall,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Paciente',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Opciones principales
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.note_alt_outlined,
                  title: 'Ver Notas',
                  subtitle: 'Revisar las notas del paciente',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PatientNotesPage(patient: patient),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.task_alt_outlined,
                  title: 'Ver Tareas',
                  subtitle: 'Gestionar tareas asignadas',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PatientTasksPage(patient: patient),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // NUEVA OPCIÓN PARA OBSERVACIONES - USAR Navigator.push en lugar de context.pushNamed
                _ActionButton(
                  icon: Icons.visibility_outlined,
                  title: 'Ver Observaciones',
                  subtitle: 'Gestionar observaciones del paciente',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PatientObservationsPage(patient: patient),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.info_outlined,
                  title: 'Ver Detalles',
                  subtitle: 'Información completa del paciente',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.of(context).pop();
                    _showPatientDetails(context);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

  void _showPatientDetails(BuildContext context) {
    final cleanEmail = _cleanEmailText(patient.email);
    final cleanGender = _cleanGenderText(patient.gender);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle para cerrar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header del modal
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha((0.1 * 255).round()),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              patient.name.isNotEmpty 
                                  ? patient.name.substring(0, 1).toUpperCase()
                                  : 'P',
                              style: GoogleFonts.interTight(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.fullName,
                                style: GoogleFonts.interTight(
                                  textStyle: Theme.of(context).textTheme.headlineSmall,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Paciente',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Título de información
                    const Text(
                      'Información del Paciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de detalles
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: cleanEmail.isNotEmpty ? cleanEmail : 'No disponible',
                      isPlaceholder: cleanEmail.isEmpty,
                    ),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: patient.phone.isNotEmpty ? patient.phone : 'No disponible',
                      isPlaceholder: patient.phone.isEmpty,
                    ),
                    _DetailRow(
                      icon: Icons.cake_outlined,
                      label: 'Fecha de Nacimiento',
                      value: DateFormat.yMMMMd('es_ES').format(patient.birthDate),
                    ),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Género',
                      value: cleanGender.isNotEmpty ? cleanGender : 'No especificado',
                      isPlaceholder: cleanGender.isEmpty,
                    ),
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'ID del Paciente',
                      value: patient.id,
                    ),
                    if (patient.createdAt != null)
                      _DetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'Registrado el',
                        value: DateFormat.yMMMMd('es_ES').format(patient.createdAt!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(100),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.interTight(
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryText.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isPlaceholder ? Colors.grey.shade500 : Colors.black,
                    fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}