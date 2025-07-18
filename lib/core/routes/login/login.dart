import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics_customer/core/config.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../components/custombuttons.dart';
import '../../components/textfield.dart';
import '../home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  bool isPass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            "XCAM Admin",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: BlocProvider(
        create: (_) => AuthBloc(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthErrorState) {
              Fluttertoast.showToast(msg: "Incorrect Email or Password");
            } else if (state is AuthLoggedInState) {
              Fluttertoast.showToast(msg: "Logged In");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Home();
                  },
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Image.asset(ImageConfig.logo, width: 150, height: 150),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: emailController,
                      label: "Email",
                      suffixIcon: const Icon(Icons.email),
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: passwordController,
                      label: "Password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPass = !isPass;
                          });
                        },
                        icon: isPass
                            ? const Icon(Icons.remove_red_eye)
                            : const Icon(Icons.visibility_off),
                      ),
                      isPassword: !isPass,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CustomButton(
                        label: "Sign In",
                        onPressed: () {
                          if (passwordController.text.length < 8) {
                            Fluttertoast.showToast(
                              msg:
                                  "Password must be at least 8 characters long",
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                            return;
                          }
                          context.read<AuthBloc>().add(
                            AuthSignInEvent(
                              email: emailController.text,
                              password: passwordController.text,
                            ),
                          );
                        },
                        backgroundColor: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Powered by",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.9),
                        ),
                      ),
                      Image.asset(ImageConfig.images, width: 70, height: 50),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
