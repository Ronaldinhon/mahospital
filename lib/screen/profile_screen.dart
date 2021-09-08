import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:mahospital/modals/local_user.dart';
// import 'package:memodx/widgets/leading_drawer.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  CollectionReference userRef = FirebaseFirestore.instance.collection('users');
  // .withConverter<LocalUser>(
  //   fromFirestore: (snapshot, _) => LocalUser.fromJson(snapshot.data()!),
  //   toFirestore: (localUser, _) => localUser.toJson(),
  // );
  late LocalUser localUser;

  @override
  void initState() {
    // getUserData();
    super.initState();
  }

  Future<DocumentSnapshot> getUserData() async {
    user = FirebaseAuth.instance.currentUser!;
    uid = user.uid;
    print(uid);
    print('common mother fuck');
    // await userRef.doc(uid).get().then((v) {
    //   print('common mother fuck 222');
    //   print(v.data()!.createdAt);
    // });
    await userRef.doc(uid).get().then((v) {
      print(v.get('email'));
      localUser = LocalUser(
          email: v.get('email'),
          imageUrl: v.get('imageUrl'),
          name: v.get('name'),
          reg: v.get('reg'),
          title: v.get('title'),
          verified: v.get('verified'),
          verifiedBy: v.get('verifiedBy'));
    });
    return userRef.doc(uid).get();
    // var person = FirebaseAuth.instance.currentUser!;
    // if (person == null) {
    //   SchedulerBinding.instance!.addPostFrameCallback((_) {
    //     Navigator.of(context).pushReplacementNamed('/login');
    //   });
    // } else {
    // }
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
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Profile'),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        // drawer: LeadingDrawer('profile'),
        backgroundColor: Theme.of(context).primaryColor,
        body:
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
            
          //   WillPopScope(
          // onWillPop: onWillPop,
          // child: 
          FutureBuilder<DocumentSnapshot>(
            future: getUserData(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.hasError);
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.connectionState == ConnectionState.done) {
                // Object? dat = snapshot.data!.data();
                // LocalUser data = LocalUser.fromJson(dat);
                // localUser = snapshot.data!.data()!;
                // print(localUser);
                // print(12345);
                return Center(
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
                              backgroundImage:
                                  NetworkImage(localUser.imageUrl)),
                          SizedBox(
                            height: 15,
                          ),
                          Text("${localUser.title} ${localUser.name}"),
                          SizedBox(
                            height: 10,
                          ),
                          Text("MMC/LJM no: ${localUser.reg}"),
                          SizedBox(
                            height: 10,
                          ),
                          // if (data['verified'])
                          //   ElevatedButton(
                          //     child: RichText(
                          //       // textAlign: ,
                          //       text: TextSpan(
                          //         children: [
                          //           WidgetSpan(
                          //               child:
                          //                   Icon(Icons.qr_code_scanner),
                          //               style: TextStyle(fontSize: 25)),
                          //           TextSpan(text: ' Verify a Colleague'),
                          //         ],
                          //       ),
                          //     ),
                          //     onPressed: () async {
                          //       final String? memberId =
                          //           await Navigator.of(context)
                          //               .push<String>(
                          //         MaterialPageRoute(
                          //           builder: (c) {
                          //             return QrView(
                          //                 'Verify a Colleague by scanning user\'s profile QR code');
                          //           },
                          //         ),
                          //       );
                          //       DocumentSnapshot<Object> coll =
                          //           await userRef.doc(memberId).get();
                          //       if (coll['verified']) {
                          //         ScaffoldMessenger.of(context)
                          //             .showSnackBar(
                          //           SnackBar(
                          //             content: Text(
                          //                 'Colleage already verified.'),
                          //           ),
                          //         );
                          //       } else {
                          //         userRef.doc(memberId).update({
                          //           'verified': true,
                          //           'verifiedBy': uid
                          //         });
                          //       }
                          //     },
                          //   ),
                          if (user != null)
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
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        // )
        );
  }
}
