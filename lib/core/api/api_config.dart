class ApiConfig {
  static const String _baseUrl = 'http://10.0.2.2'; 

  static const String appointmentBaseUrl = '$_baseUrl:3001/appointment';
  static const String identityBaseUrl = '$_baseUrl:3002/identity';
  static const String patientBaseUrl = '$_baseUrl:3003/patient';
  static const String professionalBaseUrl = '$_baseUrl:3004/professional';
  static const String diaryBaseUrl = '$_baseUrl:3005';
}