part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

@immutable
class LoginUser extends AuthEvent {
  final AuthUser user;

  LoginUser(this.user);
}

@immutable
class LogoutUser extends AuthEvent {}
