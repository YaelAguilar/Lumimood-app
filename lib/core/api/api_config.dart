import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiConfig {
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get patientBaseUrl => dotenv.env['PATIENT_BASE_URL'] ?? '';
  static String get professionalBaseUrl => dotenv.env['PROFESSIONAL_BASE_URL'] ?? '';
  static String get diaryBaseUrl => dotenv.env['DIARY_BASE_URL'] ?? '';
  static String get identityBaseUrl => dotenv.env['IDENTITY_BASE_URL'] ?? '';
  static String get appointmentBaseUrl => dotenv.env['APPOINTMENT_BASE_URL'] ?? '';

  static void printConfiguration() {
    log('🌐 API CONFIG:');
    log('  Base URL: [32m$_baseUrl[0m');
    log('  Identity: $identityBaseUrl');
    log('  Patient: $patientBaseUrl');
    log('  Professional: $professionalBaseUrl');
    log('  Appointment: $appointmentBaseUrl');
    log('  Diary: $diaryBaseUrl');
  }

  /// Verifica si las URLs están configuradas correctamente
  static bool isConfigured() {
    return _baseUrl.isNotEmpty &&
        !_baseUrl.contains('localhost') ||
        _baseUrl.contains('10.0.2.2') ||
        _baseUrl.contains('192.168.');
  }
}