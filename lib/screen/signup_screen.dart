import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/controllers/auth_controller.dart';
import 'package:mahospital/helpers/disable_paste.dart';
import 'package:mahospital/screen/login_screen.dart';
import '../widget/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:path/path.dart' as path;
// import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late firebase_storage.Reference storageRef;
  final AuthController aC = authController;
  bool _isLoadingReport = false;

  late String cPassword;
  late String cEmail;
  final HttpsCallable checkReg = FirebaseFunctions.instance.httpsCallable(
    'checkReg',
  );

  TextEditingController remail = TextEditingController();
  TextEditingController rtitle = TextEditingController();
  TextEditingController rreg = TextEditingController();
  TextEditingController rreport = TextEditingController();

  static List<String> _dropdownTitles = [
    'Dr',
    'Sn',
    'Sister',
    '',
  ];
  final String merits =
      'https://meritsmmc.moh.gov.my/search/registeredDoctor?name=';

  void initState() {
    aC.title.text = '';
    rtitle.text = '';
    super.initState();
  }

  Future<bool> containRegNumber() async {
    if (aC.title.text == 'Dr') {
      DocumentSnapshot<Object?> regNum = await drRef.doc('1').get();
      List<dynamic> regNumList = regNum.get('ids');
      if (regNumList.contains(int.parse(aC.reg.text)))
        return true;
      else
        return false;
    } else {
      DocumentSnapshot<Object?> regNum = await snRef.doc('1').get();
      List<dynamic> regNumList = regNum.get('ids');
      if (regNumList.contains(int.parse(aC.reg.text)))
        return true;
      else
        return false;
    }
  }

  void _submitAuthForm() async {
    // UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });

      // authResult =
      await auth.createUserWithEmailAndPassword(
          email: aC.email.text.trim(), password: aC.password.text.trim());
    } on PlatformException catch (error) {
      Get.snackbar(
        'Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Get.snackbar(
        'Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickedImage(XFile image) {
    aC.imageFile = image;
  }

  void _trySubmit() async {
    setState(() => _isLoading = true);
    final isValid = _formKey.currentState!.validate();
    _formKey.currentState!.save();

    if (aC.imageFile.path.isEmpty) {
      Get.snackbar(
        'Missing Image',
        'Please add an image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (await containRegNumber()) {
      Get.snackbar(
        'Used Registration Number',
        'Report if your Registration Number is used by Other Parties',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (aC.password.text.trim() != cPassword) {
      Get.snackbar(
        'Unmatched Passwords',
        'Please make sure passwords are the same.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (aC.email.text.trim().isEmpty || cEmail.isEmpty) {
      Get.snackbar(
        'Missing Email',
        'Please fill in emails.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (aC.email.text.trim() != cEmail) {
      Get.snackbar(
        'Unmatched Emails',
        'Please make sure emails are the same.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (isValid) {
      try {
        if (aC.title.text == 'Dr') {
          await checkReg.call(<String, dynamic>{
            'url':
                'https://meritsmmc.moh.gov.my/search/registeredDoctor?name=' +
                    aC.name.text.split(' ').join('+'),
            'upperName': aC.name.text.toUpperCase(),
            'reg': int.parse(aC.reg.text)
          }).then((v) {
            if (v.data) {
              Get.snackbar(
                'Valid Credentials',
                'Credentials Verified',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
              );
              _submitAuthForm();
            } else {
              Get.snackbar(
                'Invalid Credentials',
                'Please check Credentials and Register again.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
              );
              setState(() => _isLoading = false);
            }
          }).catchError((e) {
            Get.snackbar(
              'Crendential Verification Error',
              'Try again or contact admin.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
            );
            setState(() => _isLoading = false);
          });
        } else if (['Sn', 'Sister'].contains(aC.title.text)) {
          _submitAuthForm();
        }
      } catch (e) {
        Get.snackbar(
          'Account registration Error',
          'Try again or contact admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _trySubmitReport() async {
    setState(() => _isLoadingReport = true);
    final isValid = _repFormKey.currentState!.validate();
    _repFormKey.currentState!.save();

    if (remail.text.isEmpty) {
      Get.snackbar(
        'Missing Email',
        'Please fill in emails.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoadingReport = false);
      return;
    }

    if (isValid) {
      try {
        repRef.add({
          'email': remail.text,
          'title': rtitle.text,
          'reg': int.parse(rreg.text),
          'report': rreport.text,
        }).then((v) => Get.snackbar(
              'Report Submitted',
              'Please wait for Admin\'s reply.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
            ));
        rtitle.text = '';
        remail.clear();
        rreg.clear();
        rreport.clear();
        setState(() => _isLoadingReport = false);
        Get.back();
        // _submitReport();
      } catch (e) {
        Get.snackbar(
          'Report Error',
          'Try again or contact admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        setState(() => _isLoadingReport = false);
        Get.back();
      }
    }
  }

  void showReportDialog() {
    Get.defaultDialog(
        title: "Report",
        content: Form(
          key: _repFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              UserImagePicker(_pickedImage),
              DisableShortcut(
                child: TextFormField(
                  textCapitalization: TextCapitalization.none,
                  key: ValueKey('remail'),
                  enableInteractiveSelection: false,
                  toolbarOptions: ToolbarOptions(
                    copy: false,
                    paste: false,
                  ),
                  validator: EmailValidator(
                      errorText: 'Please enter a valid email address'),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                  ),
                  onSaved: (value) {
                    remail.text = value!.trim();
                  },
                ),
              ),
              DropdownButtonFormField<String>(
                key: ValueKey('rtitle'),
                decoration: InputDecoration(
                  hoverColor: Theme.of(context).primaryColor,
                  labelText: 'Title',
                ),
                value: rtitle.text,
                validator: (String? val) {
                  if (val!.trim().isEmpty) {
                    return 'Title is required!';
                  }
                },
                onChanged: (String? newValue) {
                  setState(() {
                    rtitle.text = newValue!;
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
                key: ValueKey('rreg'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val!.trim().isEmpty) {
                    return 'Registration Number is required!';
                  } else if (val.trim().length < 5) {
                    return 'Registration Number must be at least 5 characters long';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'MMC / LJM no.',
                ),
                onSaved: (value) {
                  rreg.text = value!;
                },
              ),
              TextFormField(
                key: ValueKey('rreport'),
                validator: (val) {
                  if (val!.trim().isEmpty) {
                    return 'Description is required!';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                onSaved: (value) {
                  rreport.text = value!.trim();
                },
              ),
              SizedBox(
                height: 15,
              ),
              if (_isLoadingReport) CircularProgressIndicator(),
              if (!_isLoadingReport)
                ElevatedButton(
                  onPressed: _trySubmitReport,
                  child: Text('Report'),
                ),
            ],
          ),
        ),
        barrierDismissible: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              icon: Icon(Icons.report),
              onPressed: () => showReportDialog()
              // () async {
              //   await checkReg.call(<String, dynamic>{
              //     'url':
              //         'https://meritsmmc.moh.gov.my/search/registeredDoctor?name=' +
              //             'stanley choo shen hong'.split(' ').join('+'),
              //     'upperName': 'stanley choo shen hong'.toUpperCase(),
              //     'reg': 85265
              //   }).then((v) => print(v.data));
              // }
              ,
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
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
                    UserImagePicker(_pickedImage),
                    DisableShortcut(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.none,
                        key: ValueKey('email'),
                        enableInteractiveSelection: false,
                        toolbarOptions: ToolbarOptions(
                          copy: false,
                          paste: false,
                        ),
                        validator: EmailValidator(
                            errorText: 'Please enter a valid email address'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                        ),
                        onSaved: (value) {
                          aC.email.text = value!.trim();
                        },
                      ),
                    ),
                    DisableShortcut(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.none,
                        key: ValueKey('cemail'),
                        enableInteractiveSelection: false,
                        toolbarOptions: ToolbarOptions(
                          copy: false,
                          paste: false,
                        ),
                        validator: EmailValidator(
                            errorText: 'Please enter a valid email address'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                        ),
                        onSaved: (value) {
                          cEmail = value!.trim();
                        },
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey('title'),
                      decoration: InputDecoration(
                        hoverColor: Theme.of(context).primaryColor,
                        labelText: 'Title',
                        // labelStyle: title == null
                        //     ? null
                        //     : TextStyle(color: Theme.of(context).primaryColor)
                      ),
                      value: aC.title.text,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return 'Title is required!';
                        }
                      },
                      // RequiredValidator(errorText: 'Title is required'),
                      onChanged: (String? newValue) {
                        // Focus.of(context).nextFocus();
                        // FocusScope.of(context).requestFocus(new FocusNode());
                        setState(() {
                          aC.title.text = newValue!;
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
                      decoration: InputDecoration(
                        labelText: 'Registered Name',
                      ),
                      onSaved: (value) {
                        aC.name.text = value!.trim();
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
                      decoration: InputDecoration(
                        labelText: 'Short Name',
                      ),
                      onSaved: (value) {
                        aC.shortName.text = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: ValueKey('reg'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Registration Number is required!';
                        } else if (val.trim().length < 5) {
                          return 'Registration Number must be at least 5 characters long';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'MMC / LJM no.',
                      ),
                      onSaved: (value) {
                        aC.reg.text = value!;
                      },
                    ),
                    TextFormField(
                      key: ValueKey('password'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Password is required!';
                        } else if (val.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Password', hintText: 'Numbers only'),
                      obscureText: true,
                      onSaved: (value) {
                        aC.password.text = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: ValueKey('cpassword'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Password is required!';
                        } else if (val.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Numbers only'),
                      obscureText: true,
                      onSaved: (value) {
                        cPassword = value!;
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
                        onPressed: () => Get.off(LoginScreen()),
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

// var response = await http.Client().get(
//     Uri.parse(merits + name.trim().split(' ').join('+')),
//     headers: {
//       "Access-Control-Allow-Origin": "*",
//       "Accept": "application/json"
//     });
// var upperName = name.trim().toUpperCase();
// List<String> lines = LineSplitter.split(response.body).toList();
// var nameLine = lines.firstWhere((line) => line.contains(upperName));
// var name1 =
//     nameLine.split('<').firstWhere((l) => l.contains(upperName));
// var name2 = name1.split('>').firstWhere((l) => l.contains(upperName));
// List<String> urls = [];
// if (nameLine.length != 0 && upperName == name2) {
//   lines.where((l) => l.contains('viewDoctor')).forEach((l) {
//     var viewDr =
//         l.split(';').firstWhere((l) => l.contains('viewDoctor'));
//     urls.add(
//         viewDr.split('&').firstWhere((l) => l.contains('viewDoctor')));
//   });
//   if (await checkRegNum(urls)) {
//     Get.snackbar(
//       'Valid Credentials',
//       'Registration in Progress',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//     );
//   } else {
//   }
// } else {
//   Get.snackbar(
//     'Invalid Credentials',
//     'Please check Credentials and Register again.',
//     snackPosition: SnackPosition.BOTTOM,
//     backgroundColor: Colors.red,
//   );
// }

// Future<bool> checkRegNum(List<String> urls) async {
//   for (var i = 0; i < urls.length; i++) {
//     var res = await http.get(Uri.parse(urls[i]), headers: {
//       "Access-Control-Allow-Origin": "*",
//       "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
//     });
//     List<String> lines = LineSplitter.split(res.body).toList();
//     var full =
//         lines.firstWhere((l) => l.contains('Full Registration Number'));
//     var provi = lines
//         .firstWhere((l) => l.contains('Provisional Registration Number'));
//     if (provi.length != 0 || full.length != 0) {
//       if (provi.contains(reg.toString()) || full.contains(reg.toString()))
//         return true;
//       else
//         continue;
//     }
//   }
//   return false;
// }

// void addDrOrSnRegNumber() async {
//   if (title == 'Dr') {
//     DocumentSnapshot<Object?> regNum = await drRef.doc('1').get();
//     List<dynamic> regNumList = regNum.get('ids');
//     regNumList.add(reg);
//     drRef.doc('1').update({'ids': regNumList});
//   } else {
//     DocumentSnapshot<Object?> regNum = await snRef.doc('1').get();
//     List<dynamic> regNumList = regNum.get('ids');
//     regNumList.add(reg);
//     drRef.doc('1').update({'ids': regNumList});
//   }
// }

//     .then((uc) {
//   uc.user!.sendEmailVerification();
//   addDrOrSnRegNumber();
//   return uc;
// });

// await authResult.user!.sendEmailVerification().then((_) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: const Text(
//           '''An email has just been sent to you. Click the link provided to complete registration.'''),
//     ),
//   );
// });

// final ref = FirebaseStorage.instance
//     .ref()
//     .child('user_images')
//     .child(authResult.user.uid + '.jpg');
// ref.putFile(imageFile).whenComplete(() async {
//   url = await ref.getDownloadURL();
// });

// String url;
// storageRef = storage
//     .ref()
//     .child('user_images')
//     .child(path.basename(aC.imageFile.path));
// url = (await storageRef.putFile(aC.imageFile).whenComplete(() async {
//   return await storageRef.getDownloadURL();
// })) as String;

// await userRef.doc(authResult.user!.uid).set({
//   'name': name,
//   'shortName': shortName,
//   'email': email,
//   'title': title,
//   'reg': reg,
//   'imageUrl': url,
//   'role': 'user',
//   'verified': false,
//   'verifiedBy': null,
//   'createdAt': DateTime.now().millisecondsSinceEpoch,
//   'updatedAt': DateTime.now().millisecondsSinceEpoch,
// });

// snRef.doc('1').
// need to test cloud function first
// auth.signOut();
// Navigator.of(context).pushReplacementNamed('/profile');
// setState(() {
//   _isLoading = false;
// });
// var message = 'Error occured. Please login/register again.';
// if (error.message != null) {
//   message = error.message!;
// }
// ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//     content: Text(message),
//     backgroundColor: Theme.of(context).errorColor,
//   ),
// );
