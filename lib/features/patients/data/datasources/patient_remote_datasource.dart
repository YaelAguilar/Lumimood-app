import 'dart:convert';
import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getAllPatients();
  Future<List<PatientModel>> getPatientsByProfessional(String professionalId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final ApiClient apiClient;

  PatientRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PatientModel>> getAllPatients() async {
    final url = '${ApiConfig.patientBaseUrl}/patient/';
    log('👥 PATIENTS API: Fetching all patients from: $url');
    
    try {
      final response = await apiClient.get(url);
      log('👥 PATIENTS API: Response status: ${response.statusCode}');
      log('👥 PATIENTS API: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // El endpoint /patient/ devuelve solo IDs: {"status":"success","message":"Pacientes encontrados","result":["id1","id2"]}
        List<String>? patientIds;
        if (responseData is Map<String, dynamic> && responseData.containsKey('result')) {
          patientIds = List<String>.from(responseData['result']);
        }
        
        if (patientIds == null || patientIds.isEmpty) {
          log('⚠️ PATIENTS API: No patient IDs found in response');
          return [];
        }

        log('👥 PATIENTS API: Found ${patientIds.length} patient IDs, fetching details...');
        
        // Ahora necesitamos obtener los detalles de cada paciente individualmente
        List<PatientModel> patients = [];
        
        for (String patientId in patientIds) {
          try {
            final patientUrl = '${ApiConfig.patientBaseUrl}/patient/$patientId';
            log('👥 PATIENTS API: Fetching patient details from: $patientUrl');
            
            final patientResponse = await apiClient.get(patientUrl);
            
            if (patientResponse.statusCode == 200) {
              final patientData = json.decode(patientResponse.body);
              
              // Buscar los datos del paciente en la respuesta
              Map<String, dynamic>? patientInfo;
              if (patientData is Map<String, dynamic>) {
                if (patientData.containsKey('result')) {
                  patientInfo = patientData['result'] as Map<String, dynamic>?;
                } else if (patientData.containsKey('data')) {
                  patientInfo = patientData['data'] as Map<String, dynamic>?;
                } else if (patientData.containsKey('patient')) {
                  patientInfo = patientData['patient'] as Map<String, dynamic>?;
                } else {
                  // Si no hay wrapper, usar la respuesta directamente
                  patientInfo = patientData;
                }
              }
              
              if (patientInfo != null) {
                // Asegurar que el ID esté presente
                if (!patientInfo.containsKey('idPatient') && !patientInfo.containsKey('id')) {
                  patientInfo['idPatient'] = patientId;
                }
                
                final patient = PatientModel.fromJson(patientInfo);
                patients.add(patient);
                log('✅ PATIENTS API: Successfully parsed patient: ${patient.fullName}');
              } else {
                log('⚠️ PATIENTS API: No patient info found for ID: $patientId');
              }
            } else {
              log('❌ PATIENTS API: Failed to fetch patient $patientId - Status: ${patientResponse.statusCode}');
            }
          } catch (e) {
            log('❌ PATIENTS API: Error fetching patient $patientId - $e');
            // Continuar con el siguiente paciente en caso de error
            continue;
          }
        }
        
        log('✅ PATIENTS API: Successfully fetched ${patients.length} out of ${patientIds.length} patients');
        return patients;
        
      } else if (response.statusCode == 404) {
        log('👥 PATIENTS API: No patients found (404)');
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

  @override
  Future<List<PatientModel>> getPatientsByProfessional(String professionalId) async {
    final url = '${ApiConfig.patientBaseUrl}/patient/professional/$professionalId';
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
                        responseData['records'] ??
                        responseData['result'];
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