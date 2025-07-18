library auth_bloc;

import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../models/error.dart';
import '../../repo/auth.dart';
import '../../utilities/localStorage.dart';
import '../../utilities/logger.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<AuthLoggedInEvent>(_autoLogin);
    on<AuthSignInEvent>(_signIn);
  }

  Future<void> _autoLogin(AuthLoggedInEvent event, emit) async {
    emit(AuthLoadingState());
    try {
      String token = await SecureLocalStorage.getValue("token");
      if (token.isNotEmpty) {
        emit(AuthLoggedInState());
      } else {
        emit(AuthLoggedOutState());
      }
    } catch (e) {
      CustomLogger.error(e);
      emit(AuthErrorState(error: ErrorModel(message: "Error", e: e)));
    }
  }

  Future<void> _signIn(AuthSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      String token = await signIn(event.email, event.password);
      SecureLocalStorage.setValue("token", token);
      emit(AuthLoggedInState());
    } catch (e) {
      CustomLogger.error(e);
      emit(
        AuthErrorState(
          error: ErrorModel(message: "Error Signing In", e: e),
        ),
      );
    }
  }
}
