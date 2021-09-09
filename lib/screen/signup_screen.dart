import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:form_field_validator/form_field_validator.dart';
import 'package:path/path.dart' as path;
import '../widget/user_image_picker.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late String errorMessage;
  // String uid;
  late firebase_storage.Reference storageRef;
  CollectionReference drRef =
        FirebaseFirestore.instance.collection('drId');
  CollectionReference snRef =
        FirebaseFirestore.instance.collection('snId');

  late String email;
  late String password;
  late String name;
  late String shortName;
  late String title;
  late int reg;
  late File imageFile;
  late bool isLogin;
  late BuildContext ctx;

  static List<String> _dropdownTitles = [
    'Dr',
    'Sn',
    'Sister',
  ];
  final String merits =
      'https://meritsmmc.moh.gov.my/search/registeredDoctor?name=';

  void _submitAuthForm() async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });

      authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await authResult.user!.sendEmailVerification().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                '''An email has just been sent to you. Click the link provided to complete registration.'''),
          ),
        );
      });

      // final ref = FirebaseStorage.instance
      //     .ref()
      //     .child('user_images')
      //     .child(authResult.user.uid + '.jpg');
      // ref.putFile(imageFile).whenComplete(() async {
      //   url = await ref.getDownloadURL();
      // });

      String url;
      storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(path.basename(imageFile.path));
      url = (await storageRef.putFile(imageFile).whenComplete(() async {
        return await storageRef.getDownloadURL();
        // .then((val) {
        //   url = val;
        // });
      })) as String;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
        'name': name,
        'shortName': shortName,
        'email': email,
        'title': title,
        'reg': reg,
        'imageUrl': url,
        'verified': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      // snRef.doc('1').
      // need to test cloud function first
      _auth.signOut();
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacementNamed('/profile');
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
      errorMessage = error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickedImage(File image) {
    imageFile = image;
  }

  Future<bool> checkRegNum(List<String> urls) async {
    for (var i = 0; i < urls.length; i++) {
      var res = await http.get(Uri.parse(urls[i]));
      List<String> lines = LineSplitter.split(res.body).toList();
      var full =
          lines.firstWhere((l) => l.contains('Full Registration Number'));
      var provi = lines
          .firstWhere((l) => l.contains('Provisional Registration Number'));
      if (provi.length != 0 || full.length != 0) {
        if (provi.contains(reg.toString()) || full.contains(reg.toString()))
          return true;
        else
          continue;
      }
    }
    return false;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add an image'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = !_isLoading;
      });
      try {
        if (title == 'Dr') {
          var response = await http
              .get(Uri.parse(merits + name.trim().split(' ').join('+')));
          var upperName = name.trim().toUpperCase();
          List<String> lines = LineSplitter.split(response.body).toList();
          var nameLine = lines.firstWhere((line) => line.contains(upperName));
          var name1 =
              nameLine.split('<').firstWhere((l) => l.contains(upperName));
          var name2 = name1.split('>').firstWhere((l) => l.contains(upperName));
          List<String> urls = [];
          if (nameLine.length != 0 && upperName == name2) {
            lines.where((l) => l.contains('viewDoctor')).forEach((l) {
              var viewDr =
                  l.split(';').firstWhere((l) => l.contains('viewDoctor'));
              urls.add(viewDr
                  .split('&')
                  .firstWhere((l) => l.contains('viewDoctor')));
            });
            if (await checkRegNum(urls)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Valid credentials.'),
                ),
              );
              _submitAuthForm();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Check credentials and register again.'),
                  backgroundColor: Theme.of(context).errorColor,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Check credentials and register again.'),
                backgroundColor: Theme.of(context).errorColor,
              ),
            );
          }
        } else if (['Sn', 'Sister'].contains(title)) {
          _submitAuthForm();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Account registration error occured. Try again or contact admin.'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
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
                  UserImagePicker(_pickedImage),
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
                      email = value!;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    key: ValueKey('title'),
                    decoration: InputDecoration(
                        hoverColor: Theme.of(context).primaryColor,
                        labelText: 'Title',
                        labelStyle: title == null
                            ? null
                            : TextStyle(color: Theme.of(context).primaryColor)
                            ),
                    value: title,
                    validator:
                        RequiredValidator(errorText: 'Title is required'),
                    onChanged: (String? newValue) {
                      // Focus.of(context).nextFocus();
                      FocusScope.of(context).requestFocus(new FocusNode());
                      setState(() {
                        title = newValue!;
                      });
                    },
                    items: _dropdownTitles.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    key: ValueKey('name'),
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val!.trim().isEmpty) {
                        return 'Name is required!';
                      } else if (val.trim().length < 3) {
                        return 'Name must be at least 3 characters long';
                      }
                      return null;
                    },
                    // MinLengthValidator(3,
                    //     errorText:
                    //         'Name must be at least 3 characters long'),
                    decoration: InputDecoration(
                      labelText: 'Registered Name',
                    ),
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('shortName'),
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val!.trim().isEmpty) {
                        return 'Short name is required!';
                      } else if (val.trim().length > 9) {
                        return 'Short name must be 8 characters or shorter';
                      }
                      return null;
                    },
                    // MaxLengthValidator(8,
                    //     errorText:
                    //         'Short name must be 8 characters or shorter'),
                    decoration: InputDecoration(
                      labelText: 'Short Name',
                    ),
                    onSaved: (value) {
                      shortName = value!;
                    },
                  ),
                  TextFormField(
                    key: ValueKey('reg'),
                    validator: MinLengthValidator(5,
                        errorText:
                            'MMC / LJM number must be at least 5 digits long'),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'MMC / LJM no.',
                    ),
                    onSaved: (value) {
                      reg = int.parse(value!);
                    },
                  ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: MinLengthValidator(6,
                        errorText:
                            'Password must be at least 6 digits long'),
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
                      onPressed: _trySubmit,
                      child: Text('Signup'),
                    ),
                  if (!_isLoading)
                    TextButton(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      child: Text('Already have an account'),
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/login'),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
