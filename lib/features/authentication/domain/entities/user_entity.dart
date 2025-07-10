import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? lastName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.lastName,
  });

  @override
  List<Object?> get props => [id, email, name, lastName];
}