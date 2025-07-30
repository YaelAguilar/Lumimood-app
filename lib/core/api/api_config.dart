import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get patientBaseUrl => dotenv.env['PATIENT_BASE_URL'] ?? '';
  static String get professionalBaseUrl => dotenv.env['PROFESSIONAL_BASE_URL'] ?? '';
  static String get diaryBaseUrl => dotenv.env['DIARY_BASE_URL'] ?? '';
  static String get identityBaseUrl => dotenv.env['IDENTITY_BASE_URL'] ?? '';
  static String get appointmentBaseUrl => dotenv.env['APPOINTMENT_BASE_URL'] ?? '';
  static String get taskBaseUrl => dotenv.env['TASK_BASE_URL'] ?? '';
  static String get notificationBaseUrl => dotenv.env['NOTIFICATION_BASE_URL'] ?? '';

  static void printConfiguration() {
    log('🌐 API CONFIG:');
    log('  Base URL: $_baseUrl');
    log('  Identity: $identityBaseUrl');
    log('  Patient: $patientBaseUrl');
    log('  Professional: $professionalBaseUrl');
    log('  Appointment: $appointmentBaseUrl');
    log('  Diary: $diaryBaseUrl');
    log('  Task: $taskBaseUrl');
    log('  Notification: $notificationBaseUrl');
    
    // Verificar si las URLs están configuradas
    if (!isConfigured()) {
      log('⚠️ WARNING: API URLs are not properly configured!');
      log('⚠️ Make sure your .env file contains all required URLs');
      
      // Sugerir configuración según la plataforma
      if (Platform.isAndroid) {
        log('💡 TIP: For Android emulator, use 10.0.2.2 instead of localhost');
      } else if (Platform.isIOS) {
        log('💡 TIP: For iOS simulator, localhost should work fine');
      }
    }
  }

  /// Verifica si las URLs están configuradas correctamente
  static bool isConfigured() {
    // Verificar que todas las URLs necesarias estén configuradas
    final urlsConfigured = _baseUrl.isNotEmpty &&
        identityBaseUrl.isNotEmpty &&
        patientBaseUrl.isNotEmpty &&
        professionalBaseUrl.isNotEmpty &&
        appointmentBaseUrl.isNotEmpty &&
        diaryBaseUrl.isNotEmpty;
        
    // Verificar que no sean localhost si estamos en Android
    if (Platform.isAndroid && _baseUrl.contains('localhost')) {
      log('⚠️ WARNING: Using localhost on Android. Should use 10.0.2.2 for emulator');
      return false;
    }
    
    return urlsConfigured;
  }
  
  /// Obtiene la URL base correcta según la plataforma
  static String getPlatformAwareUrl(String url) {
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }
}