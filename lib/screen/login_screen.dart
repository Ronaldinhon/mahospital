// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/controllers/auth_controller.dart';
import 'package:mahospital/screen/signup_screen.dart';
// import 'package:mahospital/provider/auth_model.dart';
// import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  // late String email;
  // late String password;
  // late Stream<User?> userStream;
  // late String errorMessage;

  @override
  void initState() {
    // userStream = _auth.authStateChanges();
    // listenAuthChange();
    if (authController.remindCompleteRegistration)
      Future.delayed(
          const Duration(milliseconds: 1500), () => remindSnackbar());
    super.initState();
  }

  void remindSnackbar() {
    Get.snackbar(
      "Please Complete Registration",
      '''An email has been sent to you. Click the link provided to complete registration.''',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
    );
  }

  // void listenAuthChange() async {
  //  userStream.listen((User? user) {
  //     if (user != null && !user.emailVerified) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text(
  //               '''An email has just been sent to you. Click the link provided to complete registration.'''),
  //         ),
  //       );
  //       _auth.signOut();
  //     } else if (user != null) {
  //       Navigator.of(context).pushReplacementNamed('/profile');
  //     }
  //   });
  // }

  void _tryLogin() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      if (await authController.signIn()) {
        setState(() => _isLoading = false);
      }
    }
  }

  // @override
  // void dispose() {
  //   userStream
  //   super.dispose();
  // }

  final focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: authController.email,
                      textCapitalization: TextCapitalization.none,
                      key: ValueKey('email'),
                      validator: EmailValidator(
                          errorText: 'Please enter a valid email address'),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email address',
                      ),
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).requestFocus(focus);
                      },
                      // onFieldSubmitted: (val) => _tryLogin(),
                    ),
                    TextFormField(
                      focusNode: focus,
                      controller: authController.password,
                      keyboardType: TextInputType.number,
                      key: ValueKey('password'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: MinLengthValidator(6,
                          errorText: 'Password must be at least 6 digits long'),
                      decoration: InputDecoration(
                          labelText: 'Password', hintText: 'Numbers only'),
                      // autofillHints: ['Only numbers'],
                      obscureText: true,
                      onFieldSubmitted: (val) => _tryLogin(),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (_isLoading) CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: () => _tryLogin(),
                        child: Text('Login'),
                      ),
                    if (!_isLoading)
                      TextButton(
                        style: TextButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () => Get.to(SignupScreen()),
                        child: Text('Create an account'),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
