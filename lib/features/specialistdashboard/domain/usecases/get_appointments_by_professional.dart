import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentsByProfessional implements UseCase<List<AppointmentEntity>, GetAppointmentsParams> {
  final AppointmentRepository repository;

  GetAppointmentsByProfessional(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(GetAppointmentsParams params) async {
    return await repository.getAppointmentsByProfessional(params.professionalId, params.date);
  }
}

class GetAppointmentsParams extends Equatable {
  final String professionalId;
  final DateTime date;

  const GetAppointmentsParams({required this.professionalId, required this.date});

  @override
  List<Object?> get props => [professionalId, date];
}