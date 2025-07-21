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
    try {
      await remoteDataSource.register(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure('Error de red: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> registerSpecialist(RegisterSpecialistParams params) async {
    try {
      await remoteDataSource.registerSpecialist(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure('Error de red: ${e.toString()}'));
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