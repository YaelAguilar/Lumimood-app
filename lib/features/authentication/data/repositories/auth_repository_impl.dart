import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({required String email, required String password}) async {
    try {
      final remoteUser = await remoteDataSource.login(email: email, password: password);
      return Right(remoteUser);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String lastName,
    String? secondLastName,
    required String email,
    required String password,
    required String gender,
  }) async {
    try {
      final remoteUser = await remoteDataSource.register(
        name: name,
        lastName: lastName,
        secondLastName: secondLastName,
        email: email,
        password: password,
        gender: gender,
      );
      return Right(remoteUser);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}