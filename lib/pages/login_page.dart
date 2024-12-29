// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:minimalchat/services/auth/auth_services.dart';
import 'package:minimalchat/components/button.dart';
import 'package:minimalchat/components/textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onTap});
  final void Function()? onTap;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    print('touched');
    final AuthService authService = AuthService();
    try {
      await authService.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('$e'),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.message_sharp,
            size: 70,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('welcome'),
          const SizedBox(height: 25),
          CustomTextField(
            text: 'Email',
            obsecureText: false,
            controller: emailController,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            text: 'Password',
            obsecureText: true,
            controller: passwordController,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomButton(
            text: 'Login',
            onTap: () {
              login(context);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Not A Memeber',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Register Now',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ))
            ],
          )
        ]),
      ),
    );
  }
}
