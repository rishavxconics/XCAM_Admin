import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistics_customer/core/bloc/auth/auth_bloc.dart';
import 'package:logistics_customer/core/routes/login/mainPage.dart';
import 'package:logistics_customer/core/services/setup.dart';

void main() {
  setup("");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: MediaQuery.of(context).size,
      child: BlocProvider(
        create: (_) => AuthBloc()..add(AuthLoggedInEvent()),
        child: MaterialApp(title: 'Flutter Demo', home: const MainPage()),
      ),
    );
  }
}
