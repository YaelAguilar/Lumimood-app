import 'dart:convert';
import 'dart:developer';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/appointment_model.dart';
import 'package:intl/intl.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointmentsByProfessional(String professionalId, DateTime date);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient apiClient;

  AppointmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AppointmentModel>> getAppointmentsByProfessional(String professionalId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = '${ApiConfig.appointmentBaseUrl}/$professionalId/$formattedDate';
    log('Fetching appointments from: $url');
    
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);

      if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('appointments')) {
        final data = decodedBody['appointments'];
        if (data is List) {
          return data
              .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      throw ServerException('La respuesta del servidor no tiene el formato esperado.');
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Error al cargar las citas.';
        throw ServerException(errorMessage);
      } catch (e) {
        throw ServerException('Error al cargar las citas (respuesta inesperada).');
      }
    }
  }
}