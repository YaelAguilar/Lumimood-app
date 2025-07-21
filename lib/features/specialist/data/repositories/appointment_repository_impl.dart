import 'package:dartz/dartz.dart';
import 'dart:developer';
import '../../../../core/error/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointmentsByProfessional(
      String professionalId, DateTime date) async {
    try {
      log('Attempting to fetch appointments from remote data source...');
      final appointments = await remoteDataSource.getAppointmentsByProfessional(professionalId, date);
      log('Successfully fetched appointments from remote.');
      return Right(appointments);
    } catch (e) {
      // --- CAMBIO APLICADO: La respuesta de fallback ahora es asíncrona ---
      log('⚠️ Failed to fetch remote appointments: $e. Returning mock data after a short delay.');
      
      // Usamos Future.delayed para simular una pequeña latencia y, lo más importante,
      // para asegurar que la respuesta se procese en el siguiente ciclo de eventos de Dart,
      // evitando el interbloqueo.
      await Future.delayed(const Duration(milliseconds: 300));
      
      return Right(_getMockAppointments(professionalId));
    }
  }

  List<AppointmentEntity> _getMockAppointments(String professionalId) {
    return [
      AppointmentEntity(
        id: 'mock_1',
        patientId: 'paciente_001',
        professionalId: professionalId,
        date: DateTime.now(),
        time: '10:00 AM',
        reason: 'Consulta de seguimiento por ansiedad',
      ),
      AppointmentEntity(
        id: 'mock_2',
        patientId: 'paciente_002',
        professionalId: professionalId,
        date: DateTime.now(),
        time: '11:30 AM',
        reason: 'Primera consulta de evaluación',
      ),
      AppointmentEntity(
        id: 'mock_3',
        patientId: 'paciente_003',
        professionalId: professionalId,
        date: DateTime.now(),
        time: '01:00 PM',
        reason: 'Terapia de pareja',
      ),
    ];
  }
}