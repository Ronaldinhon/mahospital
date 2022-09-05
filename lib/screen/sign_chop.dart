import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/local_user.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/widget/leading_drawer.dart';
import 'package:mahospital/widget/user_image_picker.dart';
import 'package:number_display/number_display.dart';

class SignChop extends StatefulWidget {
  @override
  _SignChopState createState() => _SignChopState();
}

class _SignChopState extends State<SignChop> {
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

  late HandSignaturePainterView ww;
  final GlobalKey globalKey = new GlobalKey();
  final TextEditingController chop = TextEditingController();
  final display = createDisplay(
    length: 5,
  );
  // XFile imageFile = XFile('');

  void _pickedImage(XFile image) async {
    // imageFile = image;
    ecController.cc = ByteData.sublistView(await image.readAsBytes());
  }

  @override
  void initState() {
    ww = HandSignaturePainterView(
      control: control,
      color: Colors.blueGrey,
      width: 1.0,
      maxWidth: 10.0,
      type: SignatureDrawType.shape,
    );
    print(display(17400.9098)); // 17400 = 17k
    print(display(0.0990098)); // 0
    super.initState();
  }

  final HandSignatureControl control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  Future<DocumentSnapshot> getUserData() async {
    user = auth.currentUser!;
    uid = user.uid;
    if (!authController.inited) {
      getUser = userRef.doc(uid).get();
      authController.getUserFuture = getUser;
      authController.inited = true;
      await getUser.then((v) {
        authController.initializeUserModel(v);
      });
    } else {
      getUser = authController.getUserFuture;
    }
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.connectionState == ConnectionState.done) {
          UserModel u = userController.user;
          return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Sign & Chop'),
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
              drawer: LeadingDrawer('sign_chop'),
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
                            SizedBox(
                              height: 15,
                            ),
                            Text("${u.title} ${u.name}"),
                            Text("MMC / LJM no: ${u.reg}"),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                constraints: BoxConstraints(
                                    minHeight: 200, minWidth: 200),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                )),
                                child: ww),
                            SizedBox(
                              height: 4,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // put a small circular avatar with sign image as the background
                                // click and show the sign like a xray picture
                                ElevatedButton(
                                    child: Icon(Icons.save),
                                    onPressed: () async => ecController.bb =
                                        await control.toImage(
                                            background: Colors.white)),
                                ElevatedButton(
                                    child: Icon(Icons.delete),
                                    onPressed: () => control.clear())
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            UserImagePicker(_pickedImage),
                            // ElevatedButton(
                            //     child: Icon(Icons.save),
                            //     onPressed: () => null // _captureAndSharePng()
                            //     ),
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
