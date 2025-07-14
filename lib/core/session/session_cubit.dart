import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/authentication/domain/entities/user_entity.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final SharedPreferences sharedPreferences;

  SessionCubit({required this.sharedPreferences}) : super(const UnknownSessionState());

  Future<void> showSession(UserEntity user, String token) async {
    await sharedPreferences.setString('jwt_token', token);
    await sharedPreferences.setString('user_id', user.id);
    await sharedPreferences.setString('user_email', user.email);
    await sharedPreferences.setString('user_name', user.name);
    await sharedPreferences.setString('user_type', user.typeAccount.toString());

    emit(AuthenticatedSessionState(user: user, token: token));
  }

  Future<void> signOut() async {
    await sharedPreferences.clear();
    emit(const UnauthenticatedSessionState());
  }
}