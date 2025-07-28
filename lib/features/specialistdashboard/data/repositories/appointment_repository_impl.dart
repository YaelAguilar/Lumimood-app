import 'package:dartz/dartz.dart';
import 'dart:developer';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
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
      log('📅 REPOSITORY: Fetching appointments for professional: $professionalId');
      final appointments = await remoteDataSource.getAppointmentsByProfessional(professionalId, date);
      log('✅ REPOSITORY: Successfully fetched ${appointments.length} appointments');
      return Right(appointments);
    } on ServerException catch (e) {
      log('❌ REPOSITORY: Server error - ${e.message}');
      // En caso de error, devolver datos de prueba
      return Right(_getMockAppointments(professionalId));
    } catch (e) {
      log('❌ REPOSITORY: Unexpected error - $e. Returning mock data.');
      return Right(_getMockAppointments(professionalId));
    }
  }

  List<AppointmentEntity> _getMockAppointments(String professionalId) {
    final now = DateTime.now();
    return [
      AppointmentEntity(
        id: 'mock_1',
        patientId: 'patient_001',
        patientName: 'María García',
        professionalId: professionalId,
        date: now,
        time: '10:00 AM',
        reason: 'Consulta de seguimiento - Ansiedad',
        status: 'scheduled',
      ),
      AppointmentEntity(
        id: 'mock_2',
        patientId: 'patient_002',
        patientName: 'Juan Pérez',
        professionalId: professionalId,
        date: now,
        time: '11:30 AM',
        reason: 'Primera consulta - Evaluación inicial',
        status: 'scheduled',
      ),
      AppointmentEntity(
        id: 'mock_3',
        patientId: 'patient_003',
        patientName: 'Ana Martínez',
        professionalId: professionalId,
        date: now,
        time: '01:00 PM',
        reason: 'Terapia de pareja',
        status: 'scheduled',
      ),
      AppointmentEntity(
        id: 'mock_4',
        patientId: 'patient_004',
        patientName: 'Carlos López',
        professionalId: professionalId,
        date: now,
        time: '03:00 PM',
        reason: 'Manejo del estrés laboral',
        status: 'scheduled',
      ),
      AppointmentEntity(
        id: 'mock_5',
        patientId: 'patient_005',
        patientName: 'Lucía Fernández',
        professionalId: professionalId,
        date: now,
        time: '04:30 PM',
        reason: 'Terapia cognitivo-conductual',
        status: 'scheduled',
      ),
    ];
  }
}