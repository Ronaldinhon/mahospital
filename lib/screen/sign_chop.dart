import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hand_signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/local_user.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/widget/leading_drawer.dart';
import 'package:mahospital/widget/user_image_picker.dart';
import 'package:number_display/number_display.dart';

import '../helpers/fonts/center_bold.dart';
import '../helpers/reponsiveness.dart';
import 'test_sc_disc_note.dart';

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

  late HandSignature ww;
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
    ww = HandSignature(
      control: control,
      color: Colors.black,
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
                // leading: IconButton(
                //   icon: Icon(Icons.menu),
                //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                // ),
                // actions: [
                //   IconButton(
                //     icon: Icon(Icons.logout),
                //     onPressed: () => authController.signOut(),
                //   )
                // ],
              ),
              // drawer: LeadingDrawer('sign_chop'),
              backgroundColor: Colors.white,
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth:
                          ResponsiveWidget.isSmallScreen(context) ? 300 : 400),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CenterBoldText("${u.title} ${u.name}"),
                        CenterBoldText("MMC / LJM no: ${u.reg}"),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Sign here:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Container(
                            constraints:
                                BoxConstraints(minHeight: 240, minWidth: 240),
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
                                child: Icon(Icons.delete),
                                onPressed: () => control.clear()),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red)),
                                child: Icon(Icons.save),
                                onPressed: () async => ecController.bb =
                                    await control.toImage(
                                        background: Colors.white)),
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              SizedBox(
                                height: 8,
                              ),
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Try Out Sign & Chop before ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.save,
                                        color: Colors.red,
                                        size: 17,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' :',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                  '* Saved Signature and Chop CAN\'T be deleted',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10)),
                              ElevatedButton.icon(
                                icon: Icon(Icons.picture_as_pdf),
                                label: BoldButtonText('Try Out'),
                                // need to disable button on refresh
                                onPressed: () => Get.to(TestScDiscNote()),
                              ),
                              BoldButtonText('Saved Signature:'),
                              BoldButtonText('Saved Chop Image:'),
                              SizedBox(
                                height: 8,
                              ),
                              // Row()...
                              UserImagePicker(_pickedImage),
                              // ElevatedButton(
                              //     child: Icon(Icons.save),
                              //     onPressed: () => null // _captureAndSharePng()
                              //     ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
