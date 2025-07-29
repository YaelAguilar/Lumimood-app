import 'dart:convert';
import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatientsByProfessional(String professionalId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final ApiClient apiClient;

  PatientRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PatientModel>> getPatientsByProfessional(String professionalId) async {
    final url = '${ApiConfig.patientBaseUrl}/professional/$professionalId';
    log('👥 PATIENTS API: Fetching patients for professional: $professionalId');
    log('🌐 PATIENTS API: Making GET request to: $url');
    
    try {
      final response = await apiClient.get(url);
      log('👥 PATIENTS API: Response status: ${response.statusCode}');
      log('👥 PATIENTS API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Buscar los pacientes en diferentes posibles claves
        List<dynamic>? patientsData;
        if (responseData is List) {
          patientsData = responseData;
        } else if (responseData is Map<String, dynamic>) {
          patientsData = responseData['patients'] ?? 
                        responseData['data'] ?? 
                        responseData['records'];
        }
        
        if (patientsData == null) {
          log('⚠️ PATIENTS API: No patients found in response');
          return [];
        }

        log('👥 PATIENTS API: Found ${patientsData.length} patients');
        
        final patients = patientsData.map((json) => 
          PatientModel.fromJson(json as Map<String, dynamic>)
        ).toList();
        
        return patients;
        
      } else if (response.statusCode == 404) {
        log('👥 PATIENTS API: No patients found for professional (404)');
        return [];
      } else {
        throw ServerException('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      log('💥 PATIENTS API: Error: $e');
      throw ServerException('Error de conexión: ${e.toString()}');
    }
  }
}