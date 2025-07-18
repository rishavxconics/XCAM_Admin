import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics_customer/core/routes/login/login.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../home.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          Fluttertoast.showToast(msg: state.error.message);
        } else if (state is AuthLoggedInState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Home();
              },
            ),
          );
        } else if (state is AuthLoggedOutState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Login();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
