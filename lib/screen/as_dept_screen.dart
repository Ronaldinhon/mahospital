import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/hosp_model.dart';
// import 'package:memodx/widgets/leading_drawer.dart';
import '/widget/user_image_picker.dart';
import 'package:path/path.dart' as path;

class AsDeptScreen extends StatefulWidget {
  final HospModel hosp;

  AsDeptScreen(this.hosp);
  @override
  _AsDeptScreenState createState() => _AsDeptScreenState();
}

class _AsDeptScreenState extends State<AsDeptScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // String errorMessage;
  late firebase_storage.Reference storageRef;
  late HospModel hospital;

  late String uid;
  late String name;
  late String shortName;
  late String hospId;
  XFile imageFile = XFile('');

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    hospital = widget.hosp;
    // getUserDept();
    super.initState();
  }

  void _pickedImage(XFile image) {
    imageFile = image;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (imageFile.path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add an image / logo'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        _submitAuthForm();
      } catch (e) {
        Get.snackbar(
          'Hospital Registration Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //         'Department registration error occured. Try again or contact admin.'),
        //     backgroundColor: Theme.of(context).errorColor,
        //   ),
        // );
      }
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  void _submitAuthForm() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String url;
      storageRef = storage
          .ref()
          .child('dept_images')
          .child(path.basename(imageFile.path));
      // if (kIsWeb) {
      Uint8List bytes = await imageFile.readAsBytes();
      await storageRef.putData(bytes);
      url = await storageRef.getDownloadURL();

      // String url;
      // storageRef = firebase_storage.FirebaseStorage.instance
      //     .ref()
      //     .child('dept_images')
      //     .child(path.basename(imageFile.path));
      // await storageRef.putFile(imageFile).whenComplete(() async {
      //   await storageRef.getDownloadURL().then((val) {
      //     url = val;
      //   });
      // });

      await deptRef.add({
        'name': name,
        'shortName': shortName,
        'imageUrl': url,
        'ownerId': uid,
        'members': [uid],
        'hospId': hospital.id,
        'hospShortName': hospital.shortName,
        'verified': false,
        'verifiedBy': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }).then((v) async {
        await deptPermRef.add({
          'deptId': v.id,
          'userId': uid,
          'authBy': uid,
          'removedBy': null,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
        final DocumentSnapshot<Object?> userData = await userRef.doc(uid).get();
        List userDepts = userData.get('deptIds') as List;
        // need to test out above line
        userDepts.add(v.id);
        await userRef.doc(uid).update({'deptIds': userDepts});
      });
      // need to return dept model? - not for now
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Get.snackbar(
        'Department Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
    } catch (error) {
      Get.snackbar(
        'Department Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add Department (${hospital.shortName})'),
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
                    TextFormField(
                      key: ValueKey('name'),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Department Name is required!';
                        } else if (val.trim().length < 4) {
                          return 'Department Name must be at least 4 characters long';
                        }
                        return null;
                      },
                      // MinLengthValidator(4,
                      //     errorText:
                      //         'Department Name must be at least 4 characters long'),
                      decoration: InputDecoration(
                        labelText: 'Department Name',
                      ),
                      onSaved: (value) {
                        name = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: ValueKey('shortName'),
                      keyboardType: TextInputType.name,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Short Name is required!';
                        } else if (val.trim().length > 9) {
                          return 'Short Name must be 8 characters or shorter';
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
                        shortName = value!.trim();
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (_isLoading) CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text('Add Department'),
                      ),
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
