part of 'auth_bloc.dart';

class AuthUser {
  String authId;
  String id;
  String name;
  String role;
  String email;
  String companyId;

  AuthUser(
      {@required this.authId,
      @required this.id,
      @required this.name,
      @required this.role,
      @required this.email,
      this.companyId})
      : assert(role == 'employee' || (role == 'employer' && companyId != null),
            'CompanyId is required when role is employer');

  AuthUser.empty();
}

class AuthState {
  AuthUser user;
  bool isLoggedIn;

  AuthState({@required this.user}) {
    isLoggedIn = true;
  }

  AuthState.init() {
    user = AuthUser.empty();
    isLoggedIn = false;
  }

  AuthState.logout() {
    user = AuthUser.empty();
    isLoggedIn = false;
  }
}
