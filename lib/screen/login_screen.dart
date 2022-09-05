import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/controllers/auth_controller.dart';
import 'package:mahospital/screen/reset_pw_screen.dart';
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
    // ocrTest();
    super.initState();
  }

  ocrTest() async {
    String text = await FlutterTesseractOcr.extractHocr(
      'assets/images/mo_truth.png',
      language: 'eng',
    );
    print(text);
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
      } else
        setState(() => _isLoading = false);
    }
  }

  // @override
  // void dispose() {
  //   userStream
  //   super.dispose();
  // }

  final focus = FocusNode();
  bool _scanning = false;
  String _extractText = '';
  File _pickedIma = File('');
  late XFile? pickedImage;
  final picker = ImagePicker();

  // final HttpsCallable checkAddMember = FirebaseFunctions.instance.httpsCallable(
  //   'checkAddMember',
  // );

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
                  // child: ListView(
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
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
                    // ElevatedButton(
                    //   child: Text('Test function'), // test unauthenticated function call only
                    //   onPressed: () async {
                    //     await checkAddMember.call(<String, dynamic>{
                    //       'adderId': 'PifZco40b8M4qaFf5nthkWvTHH23',
                    //       'newMemberId': '88lz67dGyRYlvYLTigqJP6N7m3p2',
                    //       'deptId': 'yugM79fSb48P8D06rQqE',
                    //       'hospId': '1BPiyIe6E6JAJrBOorpy',
                    //     }).then((v) {
                    //       // Get.defaultDialog(title: v.data.toString());
                    //       // setState(() => addMemberLoading = false);
                    //       print(v.data);
                    //       print(v.data['code']);
                    //     }).catchError((e) {
                    //       print(e);
                    //       Get.snackbar(
                    //         'Error Adding Member',
                    //         e.toString(),
                    //         snackPosition: SnackPosition.BOTTOM,
                    //         backgroundColor: Colors.red,
                    //       );
                    //       // setState(() => addMemberLoading = false);
                    //     });
                    //   },
                    // ),
                    if (!_isLoading)
                      TextButton(
                        style: TextButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () => Get.to(SignupScreen()),
                        child: Text('Create an account'),
                      ),
                    TextButton(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () => Get.to(ResetPWScreen()),
                      child: Text('Reset Password'),
                    ),

                    _pickedIma.path.isEmpty
                        ? Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              size: 100,
                            ),
                          )
                        : Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                image: DecorationImage(
                                  image: NetworkImage(_pickedIma
                                      .path), // changed to network image because kisweb
                                  fit: BoxFit.fill,
                                )),
                          ),
                    Container(
                      height: 50,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      // child: RaisedButton(
                      //   color: Colors.green,
                      //   child: Text(
                      //     'Pick Image with text',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      //   onPressed: () async {
                      //     setState(() {
                      //       _scanning = true;
                      //     });
                      //     pickedImage = (await picker.pickImage(
                      //         source: ImageSource.gallery));
                      //     _pickedIma = File(pickedImage!.path);
                      //     _extractText = await FlutterTesseractOcr.extractText(
                      //         _pickedIma.path,
                      //         language: 'eng',
                      //         args: {
                      //           "preserve_interword_spaces": "1",
                      //         });

                      //     var ss = await FlutterTesseractOcr.extractHocr(
                      //         _pickedIma.path,
                      //         language: 'eng',
                      //         args: {
                      //           "preserve_interword_spaces": "1",
                      //         });
                      //     List<String> vv = LineSplitter.split(ss).toList();
                      //     print(vv);
                      //     setState(() {
                      //       _scanning = false;
                      //     });
                      //   },
                      // ),
                    ),
                    SizedBox(height: 20),
                    _scanning
                        ? Center(child: CircularProgressIndicator())
                        : Icon(
                            Icons.done,
                            size: 40,
                            color: Colors.green,
                          ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        _extractText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
