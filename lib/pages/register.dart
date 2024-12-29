import 'package:flutter/material.dart';
import 'package:minimalchat/services/auth/auth_services.dart';
import 'package:minimalchat/components/button.dart';
import 'package:minimalchat/components/textfield.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});

  final void Function()? onTap;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =TextEditingController();
   final TextEditingController usernameController =TextEditingController();


  void signUp(BuildContext context) async {
    final auth = AuthService();
    if (passwordController.text == confirmPasswordController.text) {
      try {
        await auth.signUpWithEmailAndPassword(emailController.text,
            passwordController.text,usernameController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(title: Text('$e')));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text('Passwords Do Not Match'),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 50,
            ),
            const Text('Registre Here'),
            const SizedBox(height: 25),
             CustomTextField(
              text: 'Username',
              obsecureText: false,
              controller: usernameController,
            ),
             const SizedBox(
              height: 10,
            ),
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
            CustomTextField(
              text: 'Confirm Password',
              obsecureText: true,
              controller: confirmPasswordController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              text: 'Register',
              onTap: () {
                signUp(context);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already Have An Account ?',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                    onTap: onTap,
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
