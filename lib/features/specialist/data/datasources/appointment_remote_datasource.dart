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
      final List<dynamic> data = json.decode(response.body)['appointments'];
      return data.map((json) => AppointmentModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to load appointments');
    }
  }
}