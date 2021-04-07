import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.init());

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is LoginUser) {
      yield AuthState(user: event.user);
    } else if (event is LogoutUser) {
      yield AuthState.logout();
    }
  }

  loginUser(AuthUser user) {
    add(LoginUser(user));
  }

  logoutUser() {
    add(LogoutUser());
  }
}
