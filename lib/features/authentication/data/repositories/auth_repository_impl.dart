import 'package:dartz/dartz.dart';
import 'dart:developer';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_user.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/usecases/register_specialist.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required AccountType typeAccount,
  }) async {
    log('🏛️ AUTH REPOSITORY: Attempting login for email=$email, type=${typeAccount.name}');
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
        typeAccount: typeAccount.name,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure('Error de red: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> register(RegisterParams params) async {
    log('🏛️ AUTH REPOSITORY: Attempting patient registration for email=${params.email}');
    try {
      await remoteDataSource.register(params);
      log('✅ AUTH REPOSITORY: Patient registration successful');
      return const Right(null);
    } on ServerException catch (e) {
      log('❌ AUTH REPOSITORY: Patient registration failed - ${e.message}');
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      log('💥 AUTH REPOSITORY: Unexpected error during patient registration - $e');
      return Left(ServerFailure('Error de red durante registro de paciente: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> registerSpecialist(RegisterSpecialistParams params) async {
    log('🏛️ AUTH REPOSITORY: Attempting specialist registration for email=${params.email}');
    try {
      await remoteDataSource.registerSpecialist(params);
      log('✅ AUTH REPOSITORY: Specialist registration successful');
      return const Right(null);
    } on ServerException catch (e) {
      log('❌ AUTH REPOSITORY: Specialist registration failed - ${e.message}');
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      log('💥 AUTH REPOSITORY: Unexpected error during specialist registration - $e');
      return Left(ServerFailure('Error de red durante registro de especialista: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}