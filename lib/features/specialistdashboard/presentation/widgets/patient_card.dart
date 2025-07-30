import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import '../../../../core/presentation/theme.dart';
import '../../../patients/domain/entities/patient_entity.dart';

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
        _showPatientDetails(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
          children: [
            Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: GoogleFonts.interTight(
                          textStyle: textTheme.titleMedium,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$age años • $cleanGender',
                            style: GoogleFonts.inter(
                              textStyle: textTheme.bodySmall,
                              color: AppTheme.primaryText.withAlpha((0.6 * 255).round()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
            
            // EMAIL - SIEMPRE MOSTRAR (incluso si está vacío)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cleanEmail.isNotEmpty ? cleanEmail : 'Email no disponible',
                      style: textTheme.bodyMedium?.copyWith(
                        color: cleanEmail.isNotEmpty 
                          ? AppTheme.primaryText.withAlpha((0.7 * 255).round())
                          : Colors.grey.shade500,
                        fontStyle: cleanEmail.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // TELÉFONO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppTheme.primaryText.withAlpha((0.7 * 255).round()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.phone.isNotEmpty ? patient.phone : 'Teléfono no disponible',
                      style: textTheme.bodyMedium?.copyWith(
                        color: patient.phone.isNotEmpty 
                          ? AppTheme.primaryText.withAlpha((0.7 * 255).round())
                          : Colors.grey.shade500,
                        fontStyle: patient.phone.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showPatientDetails(context);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Ver detalles'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    // Limpiar formato {value: Masculino}
    if (gender.startsWith('{value:') || gender.startsWith('{value :')) {
      final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(gender);
      if (match != null) {
        return match.group(1)?.trim() ?? gender;
      }
    }
    // Limpiar comillas
    return gender.replaceAll('"', '').replaceAll("'", '').trim();
  }

  String _cleanEmailText(String email) {
    if (email.isEmpty || email == 'null') return '';
    
    // Limpiar formato {value: email@domain.com}
    if (email.startsWith('{value:') || email.startsWith('{value :')) {
      final match = RegExp(r'\{value\s*:\s*([^}]+)\}').firstMatch(email);
      if (match != null) {
        email = match.group(1)?.trim() ?? email;
      }
    }
    
    // Limpiar comillas
    email = email.replaceAll('"', '').replaceAll("'", '').trim();
    
    // Validar que sea un email válido
    if (email.contains('@') && email.contains('.')) {
      return email;
    }
    
    return '';
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const Text(
                      'Información del Paciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // EMAIL - siempre mostrar
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}