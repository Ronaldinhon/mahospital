import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mahospital/provider/auth_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  // late String errorMessage;
  late String email;
  late String password;

  @override
  void initState() {
    listenAuthChange();
    super.initState();
  }

  void listenAuthChange() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '''An email has just been sent to you. Click the link provided to complete registration.'''),
          ),
        );
        _auth.signOut();
      } else if (user != null) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    });
  }

  void _tryLogin() async {
    final isValid = _formKey.currentState!.validate();
    // UserCredential authResult;
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        Provider.of<AuthModel>(context, listen: false)
            .signIn(email: email, password: password);
        // await _auth.signInWithEmailAndPassword(
        //     email: email, password: password);
        setState(() {
          _isLoading = false;
        });
      } on PlatformException catch (error) {
        var message = 'Error occured. Please login/register again.';
        if (error.message != null) {
          message = error.message!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        print(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
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
                    textCapitalization: TextCapitalization.none,
                    key: ValueKey('email'),
                    validator: EmailValidator(
                        errorText: 'Please enter a valid email address'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                    ),
                    onSaved: (value) {
                      email = value!; //is it auto trim?
                    },
                  ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: MinLengthValidator(6,
                        errorText: 'Password must be at least 6 digits long'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (_isLoading) CircularProgressIndicator(),
                  if (!_isLoading)
                    ElevatedButton(
                      onPressed: _tryLogin,
                      child: Text('Login'),
                    ),
                  // if (!_isLoading)
                  //   TextButton(
                  //     style: TextButton.styleFrom(
                  //         primary: Theme.of(context).primaryColor),
                  //     onPressed: () =>
                  //         Navigator.of(context).pushReplacementNamed('/signup'),
                  //     child: Text('Create an account'),
                  //   )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
