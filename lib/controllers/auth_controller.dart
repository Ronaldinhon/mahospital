import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/firebase.dart';
// import 'package:mahospital/helpers/show_loading.dart';
import 'package:mahospital/screen/login_screen.dart';
import 'package:mahospital/screen/profile_screen.dart';
import '/controllers/user_controller.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
// import '/services/database.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _firebaseUser;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController name = TextEditingController();
  TextEditingController shortName = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController reg = TextEditingController();
  // File imageFile = File('');
  XFile imageFile = XFile('');
  late firebase_storage.Reference storageRef;
  bool remindCompleteRegistration = false;

  late Future<DocumentSnapshot> getUserFuture;
  bool inited = false;
  // apparently getx controller has a initialized bool

  User? get user => _firebaseUser.value;

  @override
  void onReady() {
    super.onReady();
    _firebaseUser = Rx<User?>(auth.currentUser);
    _firebaseUser.bindStream(auth.userChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (kIsWeb) auth.setPersistence(Persistence.SESSION);
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else if (!user.emailVerified) {
      userRef.doc(user.uid).get().then((ur) async {
        if (ur.exists) {
          // Get.snackbar(
          //   "Please Complete Registration",
          //   '''An email has been sent to you. Click the link provided to complete registration.''',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.blue,
          // );
          remindCompleteRegistration = true;
          signOut();
          _clearControllers();
        } else {
          user.sendEmailVerification();
          String url;
          storageRef = storage
              .ref()
              .child('user_images')
              .child(path.basename(imageFile.path + '.jpg'));
          // if (kIsWeb) {
          Uint8List bytes = await imageFile.readAsBytes();
          await storageRef.putData(bytes);
          url = await storageRef.getDownloadURL();
          // .whenComplete(() async {
          //   return await storageRef.getDownloadURL();
          // });
          // } else {
          // url = (await storageRef.putFile(imageFile).whenComplete(() async {
          //   return await storageRef.getDownloadURL();
          // })) as String;
          // }
          await userRef.doc(user.uid).set({
            'name': name.text.trim(),
            'shortName': shortName.text.trim(),
            'email': email.text.trim(),
            'reg': int.parse(reg.text.trim()),
            'title': title.text,
            'imageUrl': url,
            'role': 'user',
            'verified': false,
            'verifiedBy': null,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
            'deptIds': []
          });
          remindCompleteRegistration = true;
          signOut();
          _clearControllers();
        }
      });
    } else {
      Get.offAll(() => ProfileScreen());
      remindCompleteRegistration = false;
    }
  }

  // void createUser(String name, String email, String password) async {
  //   try {
  //     UserCredential _authResult = await auth.createUserWithEmailAndPassword(
  //         email: email.trim(), password: password.trim());
  //   } catch (e) {
  //     Get.snackbar(
  //       "Error creating Account",
  //       e.toString(),
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //     );
  //   }
  // }

  Future<bool> signIn() async {
    try {
      await auth
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: password.text.trim())
          .then((result) {
        _clearControllers();
      });
      return true;
    } catch (e) {
      Get.snackbar(
        "Sign In Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  void signOut() async {
    try {
      await auth.signOut();
      Get.find<UserController>().clear();
    } catch (e) {
      Get.snackbar(
        "Error signing out",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  void initializeUserModel(DocumentSnapshot ss) async {
    UserModel ownerOfAccount = UserModel.fromSnapshot(ss);
    userController.setUser(ownerOfAccount);
    ownerOfAccount.deptList(); // bring out so other user no need dept list
  }

  _clearControllers() {
    name.clear();
    email.clear();
    password.clear();
    shortName.clear();
    title.clear();
    reg.clear();
    imageFile = XFile('');
  }
}

// Rx<UserModel> userModel = UserModel().obs;
// UserModel get getUserModel => userModel.value;

// @override
// void onInit() {
//   _firebaseUser = Rx<User?>(auth.currentUser);
//   _firebaseUser.bindStream(auth.userChanges());
//   ever(_firebaseUser, _setInitialScreen);
//   super.onInit();
// }
//create user in database.dart
// UserModel _user = UserModel(
//   id: _authResult.user!.uid,
//   name: name,
//   email: _authResult.user!.email as String,
// );
// if (await Database().createNewUser(_user)) {
//   Get.find<UserController>().user = _user;
//   Get.back();
// }
// showLoading();
// String _userId = result.user!.uid;
// _initializeUserModel(_userId);
// dismissLoadingWidget();
// dismissLoadingWidget();
// userModel.value = await firebaseFirestore
//     .collection('users')
//     .doc(userId)
//     .get()
//     .then((doc) => UserModel.fromSnapshot(doc));
// userModel.value = ;
