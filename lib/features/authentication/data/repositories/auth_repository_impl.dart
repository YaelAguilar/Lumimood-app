import 'package:dartz/dartz.dart';
import 'dart:developer'; // Importa el paquete para poder usar la función log()
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_user.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required AccountType typeAccount,
  }) async {

    // --- LÍNEA DE DEPURACIÓN ---
    // Esta línea imprimirá en la consola exactamente qué tipo de cuenta
    // se está procesando en la capa de repositorio antes de enviarla a la red.
    log('AuthRepository: Attempting login for type: ${typeAccount.name}');
    // ----------------------------

    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
        typeAccount: typeAccount.name, // El .name convierte el enum a "patient" o "specialist"
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      // Este catch es para errores de red, como cuando el servidor no responde.
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
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}