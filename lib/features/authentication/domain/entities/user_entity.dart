import 'package:equatable/equatable.dart';

enum AccountType { patient, specialist }

extension AccountTypeExtension on String {
  AccountType toAccountType() {
    switch (this) {
      case 'patient':
        return AccountType.patient;
      case 'specialist':
        return AccountType.specialist;
      default:
        throw ArgumentError('Invalid account type string: $this');
    }
  }
}

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? lastName;
  final AccountType typeAccount;
  final String token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.lastName,
    required this.typeAccount,
    required this.token,
  });

  @override
  List<Object?> get props => [id, email, name, lastName, typeAccount, token];
}