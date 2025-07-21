import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../usecases/register_user.dart';
import '../usecases/register_specialist.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required AccountType typeAccount,
  });

  Future<Either<Failure, void>> register(RegisterParams params);

  Future<Either<Failure, void>> registerSpecialist(RegisterSpecialistParams params);

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });
}