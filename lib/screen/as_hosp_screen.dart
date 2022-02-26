// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/hosp_model.dart';
import '/screen/hosp_screen.dart';
import '/widget/leading_drawer.dart';
import '/widget/user_image_picker.dart';
import 'package:path/path.dart' as path;

class AsHospScreen extends StatefulWidget {
  @override
  _AsHospScreenState createState() => _AsHospScreenState();
}

class _AsHospScreenState extends State<AsHospScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<HospModel> hospitals = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // String errorMessage;
  late firebase_storage.Reference storageRef;

  late String uid;
  late String name;
  late String shortName;
  late String address;
  late String district;
  late String selectedHospId;
  XFile imageFile = XFile('');
  String state = '';

  static List<String> _dropdownTitles = [
    '',
    'Johor',
    'Kuala Lumpur',
    'Putrajaya',
    'Labuan',
    'Selangor',
    'Negeri Sembilan',
    'Malacca',
    'Kedah',
    'Pahang',
    'Perak',
    'Perlis',
    'Terengganu',
    'Kelantan',
    'Penang',
    'Sabah',
    'Sarawak',
  ];

  @override
  initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () => _showMyDialog());
  }

  Future<List<HospModel>> getAllHospThis() async {
    uid = auth.currentUser!.uid;
    hospitals = await hospListController.getAllHosp();
    return hospitals;
  }

  void _pickedImage(XFile image) {
    imageFile = image;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (imageFile.path.isEmpty) {
      Get.snackbar(
        'Missing Image',
        'Add an image / logo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        _submitAuthForm();
      } catch (e) {
        Get.snackbar(
          'Hospital Registration Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
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
          .child('hosp_images')
          .child(path.basename(imageFile.path));
      // if (kIsWeb) {
      Uint8List bytes = await imageFile.readAsBytes();
      await storageRef.putData(bytes);
      url = await storageRef.getDownloadURL();

      // String url;
      // storageRef = firebase_storage.FirebaseStorage.instance
      //     .ref()
      //     .child('hosp_images')
      //     .child(path.basename(imageFile.path));
      // await storageRef.putFile(imageFile).whenComplete(() async {
      //   await storageRef.getDownloadURL().then((val) {
      //     url = val;
      //   });
      // });

      await hospRef.add({
        'name': name,
        'shortName': shortName,
        'imageUrl': url,
        'address': address,
        'state': state,
        'district': district,
        'ownerId': uid,
        'members': [uid],
        'verified': false,
        'verifiedBy': null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }).then((DocumentReference<Object?> v) async {
        var hm = HospModel.fromSnapshot(await v.get());
        hospListController.addHosp(hm);
        Get.off(HospScreen(hm));
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (c) {
        //       return HospScreen(v.id);
        //     },
        //   ),
        // );
      });
      setState(() => _isLoading = false);
      // Navigator.of(context).pushReplacementNamed('/profile');
    } on PlatformException catch (error) {
      Get.snackbar(
        'Hospital Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
    } catch (error) {
      Get.snackbar(
        'Hospital Registration Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
    }
  }

  void _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminder'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                const Text(
                    'Please check for existing hospital before registering new hospital. Thank you.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> onWillPop() async {
    final shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to leave app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text('Add / Search Hospital'),
      ),
      drawer: LeadingDrawer('as_hosp'),
      backgroundColor: Theme.of(context).primaryColor,
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              margin: EdgeInsets.all(10),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      FutureBuilder<List<HospModel>>(
                        future: getAllHospThis(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<HospModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return DropdownButtonFormField<HospModel>(
                              decoration: InputDecoration(
                                hoverColor: Theme.of(context).primaryColor,
                                labelText: 'Hospital',
                              ),
                              onChanged: (HospModel? newValue) {
                                Get.to(HospScreen(newValue!));
                              },
                              items: snapshot.data!.map((HospModel value) {
                                return DropdownMenuItem<HospModel>(
                                  value: value,
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7),
                                      child: Text(value.getName())),
                                );
                              }).toList(),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Register Hospital',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.left, //dunno got use or not
                      ),
                      SizedBox(
                        height: 9,
                      ),
                      UserImagePicker(_pickedImage),
                      TextFormField(
                        key: ValueKey('name'),
                        keyboardType: TextInputType.name,
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return 'Hospital Name is required!';
                          } else if (val.trim().length < 9) {
                            return 'Hospital Name must be at least 9 characters long';
                          }
                          return null;
                        },
                        // MinLengthValidator(9,
                        //     errorText:
                        //         'Hospital Name must be at least 9 characters long'),
                        decoration: InputDecoration(
                          labelText: 'Hospital Name',
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
                          } else if (val.trim().length > 7) {
                            return 'Short name must be 6 characters or shorter';
                          }
                          return null;
                        },
                        // MaxLengthValidator(6,
                        //     errorText:
                        //         'Short name must be 6 characters or shorter'),
                        decoration: InputDecoration(
                          labelText: 'Short Name',
                        ),
                        onSaved: (value) {
                          shortName = value!.trim();
                        },
                      ),
                      TextFormField(
                        key: ValueKey('address'),
                        keyboardType: TextInputType.name,
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return 'Hospital Address is required!';
                          } else if (val.trim().length < 8) {
                            return 'Hospital Address must be at least 8 characters long';
                          }
                          return null;
                        },
                        // MinLengthValidator(8,
                        //     errorText:
                        //         'Hospital Address must be at least 8 characters long'),
                        decoration: InputDecoration(
                          labelText: 'Hospital Address',
                        ),
                        maxLines: 3,
                        onSaved: (value) {
                          address = value!.trim();
                        },
                      ),
                      DropdownButtonFormField<String>(
                        key: ValueKey('state'),
                        decoration: InputDecoration(
                          hoverColor: Theme.of(context).primaryColor,
                          labelText: 'State',
                          // labelStyle: state == null
                          //     ? null
                          //     : TextStyle(
                          //         color: Theme.of(context).primaryColor)
                        ),
                        value: state,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return 'State is required!';
                          }
                        },
                        // RequiredValidator(
                        //     errorText: 'State of Hospital is required'),
                        onChanged: (String? newValue) {
                          // Focus.of(context).nextFocus();
                          FocusScope.of(context).requestFocus(new FocusNode());
                          setState(() => state = newValue!);
                        },
                        items: _dropdownTitles.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        key: ValueKey('district'),
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return 'District is required!';
                          } else if (val.trim().length < 4) {
                            return 'District must be at least 4 characters long';
                          }
                          return null;
                        },
                        // MinLengthValidator(4,
                        //     errorText:
                        //         'District must be at least 4 character long'),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'District',
                        ),
                        onSaved: (value) {
                          district = value!.trim();
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      if (_isLoading) CircularProgressIndicator(),
                      if (!_isLoading)
                        ElevatedButton(
                          onPressed: _trySubmit,
                          child: Text('Add Hospital'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
