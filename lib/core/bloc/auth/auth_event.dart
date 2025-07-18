part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthLoggedInEvent extends AuthEvent {}

class AuthLoggedOutEvent extends AuthEvent {}

class AuthSignInEvent extends AuthEvent {
  final String email, password;

  AuthSignInEvent({required this.email, required this.password});
}
