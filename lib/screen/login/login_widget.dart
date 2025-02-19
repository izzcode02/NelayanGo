import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:gap/gap.dart';
import 'package:nelayanpos/main.dart';
import 'package:nelayanpos/utils/text_style.dart';
import 'package:nelayanpos/widget/loading.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String email = '';
  String password = '';

  bool _showPassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Container(
          height: 433,
          width: 845,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.green,
              width: 4,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(60, 33, 83, 78),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: textInter800S24,
                  ),
                  Gap(16),
                  _username(context),
                  Gap(21),
                  Text(
                    'Password',
                    style: textInter800S24,
                  ),
                  Gap(16),
                  _password(context),
                  Gap(34),
                  Center(
                    child: ElevatedButton(
                      style: const ButtonStyle(
                        minimumSize: MaterialStatePropertyAll(Size(203, 43)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                                email = emailController.text.trim();
                                password = passwordController.text.trim();
                              });
            
                              var result =
                                  await auth.signIn(email, password, context);
                              if (result != null || result == null) {
                                if (!mounted) return;
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: 0.4,
                                  child: Loading(),
                                ),
                                Text(
                                  'Loading',
                                  style: textInter700S15W,
                                ),
                              ],
                            )
                          : Text("Login", style: textInter700S15W),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _username(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "Email",
        hintStyle: TextStyle(color: Colors.black38),
        prefixIcon: Icon(
          Icons.person,
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Enter an email' : null,
      controller: emailController,
    );
  }

  Widget _password(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: Colors.black38),
        prefixIcon: Icon(
          Icons.lock,
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() => _showPassword = !_showPassword);
          },
          child: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
        ),
      ),
      validator: (value) =>
          value!.length < 6 ? 'Enter a password 6+ chars long' : null,
      controller: passwordController,
      obscureText: _showPassword,
    );
  }
}
