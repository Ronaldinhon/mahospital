import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/local_user.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/widget/leading_drawer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart';

import 'package:mahospital/cameras/qr_view.dart';

// import '../qr_view.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late User user;
  late String uid;
  late String title;
  late String username;
  late int reg;
  late String imageUrl;
  late LocalUser localUser;
  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  late UserModel u;
  late Future<DocumentSnapshot> getUser;

  // .withConverter<LocalUser>(
  //   fromFirestore: (snapshot, _) => LocalUser.fromJson(snapshot.data()!),
  //   toFirestore: (localUser, _) => localUser.toJson(),
  // );
  // above few lines is shit

  // @override
  // void initState() {
  //   // getUserData();
  //   super.initState();
  // }

  // final HttpsCallable checkAddMember = FirebaseFunctions.instance.httpsCallable(
  //   'checkAddMember',
  // );

  Future<DocumentSnapshot> getUserData() async {
    // if (FirebaseAuth.instance.currentUser == null) {
    // Navigator.of(context).pushReplacementNamed('/login');
    // } else {
    user = auth.currentUser!;
    uid = user.uid;
    if (!authController.inited) {
      getUser = userRef.doc(uid).get();
      authController.getUserFuture = getUser;
      authController.inited = true;
      await getUser.then((v) {
        authController.initializeUserModel(v);
        // localUser = LocalUser(
        //     email: v.get('email'),
        //     imageUrl: v.get('imageUrl'),
        //     name: v.get('name'),
        //     reg: v.get('reg'),
        //     title: v.get('title'),
        //     verified: v.get('verified'),
        //     verifiedBy: v.get('verifiedBy'));
      });
    } else {
      getUser = authController.getUserFuture;
    }
    // }
    return getUser;
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

  // Future<DocumentSnapshot<LocalUser>> getUser() async {
  //   // var userFuture = userRef.doc(uid).get();
  //   localUser =
  //       await userRef.doc(uid).get().then((snapshot) => snapshot.data()!);
  //   // LocalUser lUser = await (userFuture.then((v) => v.data()));
  //   return await userRef.doc(uid).get();
  // }

  @override
  Widget build(BuildContext context) {
    // UserModel u = ac.getUserModel;
    var platform = Theme.of(context).platform;
    return
        // Obx(() =>
        FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.connectionState == ConnectionState.done) {
          // UserModel u = UserModel.fromSnapshot(snapshot.!data);
          UserModel u = userController.user;
          return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Profile'),
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () => authController.signOut(),
                  )
                ],
              ),
              drawer: LeadingDrawer('profile'),
              backgroundColor: Theme.of(context).primaryColor,
              body: WillPopScope(
                  onWillPop: onWillPop,
                  child: Center(
                    child: Card(
                      margin: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CircleAvatar(
                                radius: 60,
                                backgroundColor: Color(0xffdadada),
                                backgroundImage: NetworkImage(u.imageUrl)),
                            SizedBox(
                              height: 15,
                            ),
                            Text("${u.title} ${u.name}"),
                            Text("(${u.shortName})"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("MMC / LJM no: ${u.reg}"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(u.verified ? 'Verified' : 'Not Verified'),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              child: Text('Refresh'),
                              // need to disable button on refresh
                              onPressed: () => setState(() {}),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            // ElevatedButton(
                            //   child: Text('Test function'),
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
                            // SizedBox(
                            //   height: 7,
                            // ),
                            if (u.verified && (isWebMobile || isApp))
                              ElevatedButton.icon(
                                icon: Icon(Icons.qr_code_scanner),
                                label: Text('Verify a Colleague'),
                                // child: RichText(
                                //   text: TextSpan(
                                //     children: [
                                //       WidgetSpan(
                                //         child: Icon(
                                //           Icons.qr_code_scanner,
                                //           size: 18,
                                //         ),
                                //       ),
                                //       TextSpan(
                                //           text: ' Verify a Colleague',
                                //           style: TextStyle(
                                //             color: Colors.white,
                                //           )),
                                //     ],
                                //   ),
                                // ),
                                onPressed: () async {
                                  final String? memberId =
                                      await Navigator.of(context).push<String>(
                                    MaterialPageRoute(
                                      builder: (c) {
                                        return QrView(
                                            'Scan colleague\s QR code');
                                      },
                                    ),
                                  );
                                  // Get.snackbar(
                                  //   "Show result code",
                                  //   memberId.toString(),
                                  //   snackPosition: SnackPosition.BOTTOM,
                                  //   backgroundColor: Colors.pink,
                                  // );

                                  DocumentSnapshot<Object?> coll = await userRef
                                      .doc(memberId.toString())
                                      .get();
                                  print(memberId);
                                  if (coll.exists && !coll.get('verified')) {
                                    userRef.doc(memberId).update({
                                      'verified': true,
                                      'verifiedBy': uid
                                    }).then((_) {
                                      Get.snackbar(
                                        coll.get('name') + " Verified",
                                        coll.get('shortName') +
                                            ' can now access patients\' record',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.blue,
                                      );
                                    });
                                  }
                                },
                              ),
                            QrImage(
                              backgroundColor: Colors.white,
                              data: uid,
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// user == null
//     ? Center(
//         child: ElevatedButton(
//           child: Text('Login to Continue'),
//           onPressed: () =>
//               Navigator.of(context).pushReplacementNamed('/login'),
//         ),
//       )
//     :

//remove avoid _userProvidedRouteName != null is not true error
