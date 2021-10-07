import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

final Future<FirebaseApp> initialization = Firebase.initializeApp();
final FirebaseAuth auth = FirebaseAuth.instance;
// final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
final ffi = FirebaseFirestore.instance;
final CollectionReference userRef = ffi.collection('users');
final CollectionReference deptRef = ffi.collection('depts');
final CollectionReference hospRef = ffi.collection('hosps');
final CollectionReference wardRef = ffi.collection('wards');
final CollectionReference deptPermRef = ffi.collection('deptPerms');
final CollectionReference bedRef = ffi.collection('beds');
final CollectionReference wardPtRef = ffi.collection('wardPts');
// FirebaseMessaging fcm = FirebaseMessaging.instance;
final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
CollectionReference drRef = ffi.collection('drId');
CollectionReference snRef = ffi.collection('snId');
FirebaseStorage storage = FirebaseStorage.instance;
// final FirebaseFunctions fbFunctions = FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
// fbFunctions.useFunctionsEmulator(origin: 'http://localhost:5000');
