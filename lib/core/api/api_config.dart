import 'dart:developer';

class ApiConfig {
  // Cambia estas IPs según tu configuración
  static const String _baseUrl = 'http://10.0.2.2'; // Para emulador Android
  // static const String _baseUrl = 'http://localhost'; // Para web/desktop
  // static const String _baseUrl = 'http://192.168.1.XXX'; // Para dispositivo físico (cambia la IP)

  static const String appointmentBaseUrl = '$_baseUrl:3001/appointment';
  static const String identityBaseUrl = '$_baseUrl:3002/identity';
  static const String patientBaseUrl = '$_baseUrl:3003/patient';
  static const String professionalBaseUrl = '$_baseUrl:3004/professional';
  static const String diaryBaseUrl = '$_baseUrl:3005';

  /// Imprime la configuración actual de las URLs
  static void printConfiguration() {
    log('🌐 API CONFIG:');
    log('  Base URL: $_baseUrl');
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