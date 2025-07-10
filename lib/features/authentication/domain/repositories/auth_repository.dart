import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String lastName,
    String? secondLastName,
    required String email,
    required String password,
    required String gender,
  });

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });
}