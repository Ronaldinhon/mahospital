import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import '/widget/user_image_picker.dart';
import 'package:path/path.dart' as path;

class AsWardScreen extends StatefulWidget {
  final DeptModel dept;
  AsWardScreen(this.dept);
  @override
  _AsWardScreenState createState() => _AsWardScreenState();
}

class _AsWardScreenState extends State<AsWardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late firebase_storage.Reference storageRef;
  late DeptModel deptModel;

  late String uid;
  late String name;
  late String shortName;
  late String description;
  late String deptId;
  late String hospId;
  XFile imageFile = XFile('');

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    deptModel = widget.dept;
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
      setState(() => _isLoading = true);
      try {
        _submitAuthForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ward registration error occured. Try again or contact admin.'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
        setState(() => _isLoading = false);
      }
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
          .child('ward_images')
          .child(path.basename(imageFile.path));
      // if (kIsWeb) {
      Uint8List bytes = await imageFile.readAsBytes();
      await storageRef.putData(bytes);
      url = await storageRef.getDownloadURL();

      // String url;
      // storageRef = firebase_storage.FirebaseStorage.instance
      //     .ref()
      //     .child('ward_images')
      //     .child(path.basename(imageFile.path));
      // await storageRef.putFile(imageFile).whenComplete(() async {
      //   await storageRef.getDownloadURL().then((val) {
      //     url = val;
      //   });
      // });

      // var ward =
      await wardRef.add({
        'name': name,
        'shortName': shortName,
        'description': description,
        'imageUrl': url,
        'ownerId': uid,
        'deptId': deptModel.id,
        'hospId': deptModel.hospId,
        'bedIdList': [],
        'pendingPtIds': [],
        // 'verified': false, - only created by dept owner?
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Get.snackbar(
        'Ward Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
    } catch (error) {
      Get.snackbar(
        'Ward Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add Ward (${deptModel.shortName})'),
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
                          return 'Ward Name is required!';
                        } else if (val.trim().length < 4) {
                          return 'Ward Name must be at least 4 characters long';
                        }
                        return null;
                      },
                      // MinLengthValidator(4,
                      //     errorText:
                      //         'Ward Name must be at least 4 characters long'),
                      decoration: InputDecoration(
                        labelText: 'Ward Name',
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
                        shortName = value!.trim();
                      },
                    ),
                    TextFormField(
                      key: ValueKey('description'),
                      keyboardType: TextInputType.text,
                      maxLines: 2,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Ward Description is required!';
                        } else if (val.trim().length < 4) {
                          return 'Ward Description must be at least 4 characters long';
                        }
                        return null;
                      },
                      // MinLengthValidator(4,
                      //     errorText:
                      //         'Ward Description must be at least 4 characters long'),
                      decoration: InputDecoration(
                        labelText: 'Ward Description',
                      ),
                      onSaved: (value) {
                        description = value!.trim();
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    if (_isLoading) CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text('Add Ward'),
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
