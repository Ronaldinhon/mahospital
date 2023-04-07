import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/cameras/qr_view.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/screen/qr_camera_screen.dart';
import 'package:mahospital/screen/ward_screen.dart';
import '../helpers/fonts/center_bold.dart';
import '../helpers/reponsiveness.dart';
import '/widget/leading_drawer.dart';
import 'as_ward_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '/screen/as_ward_screen.dart';
// import '/screen/ward_screen.dart';

// import '../qr_view.dart';

class DeptScreen extends StatefulWidget {
  final DeptModel deptModel;

  DeptScreen(this.deptModel);
  @override
  _DeptScreenState createState() => _DeptScreenState();
}

class _DeptScreenState extends State<DeptScreen> {
  late String uid;
  late DeptModel departmentModel;
  late List<UserModel> dmmm; //deptModelMemberModel
  late List<WardModel> dmwm; //deptModelWardModel
  bool addMemberLoading = false; // this later put into Get controller ba
  late bool isMember;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HttpsCallable checkAddMember = FirebaseFunctions.instance.httpsCallable(
    'checkAddMember',
  );

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    departmentModel = widget.deptModel;
    deptListController.getDeptsOfHosp(departmentModel.hospId);
    // iniThis();
    isMember = departmentModel.members.contains(uid);
    super.initState();
  }

  // void iniThis() async {
  //   dmmm = await departmentModel.getUserModels();
  //   dmwm = await departmentModel.getWards();
  // }

  // if cannot then only change to snapshot.data in FutureBuilder
  Future iniWards() async {
    dmwm = await departmentModel.getWards();
    return dmwm;
  }

  Future iniMembers() async {
    dmmm = await departmentModel.getUserModels();
    return dmmm;
  }

  // need some changes
  void addMember(String newMemberId) async {
    setState(() {
      addMemberLoading = true;
    });
    await checkAddMember.call(<String, dynamic>{
      'adderId': uid,
      'newMemberId': newMemberId,
      'deptId': departmentModel.id,
      'hospId': departmentModel.hospId,
      // 'url': 'https://meritsmmc.moh.gov.my/search/registeredDoctor?name=' +
      //     aC.name.text.split(' ').join('+'),
      // 'upperName': aC.name.text.toUpperCase(),
      // 'reg': int.parse(aC.reg.text)
    }).then((v) {
      // print(v.data['message']);
      // if (v.data) {
      //   Get.snackbar(
      //     'Valid Credentials',
      //     'Credentials Verified',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.green,
      //   );
      //   _submitAuthForm();
      // } else {
      //   Get.snackbar(
      //     'Invalid Credentials',
      //     'Please check Credentials and Register again.',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.red,
      //   );
      //   setState(() => _isLoading = false);
      // }
      Get.defaultDialog(title: v.data.toString());
      setState(() => addMemberLoading = false);
    }).catchError((e) {
      print(e);
      Get.snackbar(
        'Error Adding Member',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() => addMemberLoading = false);
    });

    // await deptPermRef.add({
    //   'deptId': departmentModel.id,
    //   'userId': userId,
    //   'authBy': uid,
    //   'createdAt': DateTime.now().millisecondsSinceEpoch,
    //   'updatedAt': DateTime.now().millisecondsSinceEpoch,
    // }).then((DocumentReference<Object?> v) async {
    //   DocumentSnapshot<Object?> deptLatest =
    //       await deptRef.doc(departmentModel.id).get();
    //   List mem = deptLatest['members'];
    //   mem.add(userId);
    //   deptRef.doc(departmentModel.id).update(
    //       {'members': mem, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
    //   final DocumentSnapshot<Object?> userData = await userRef.doc(uid).get();
    //   List userDepts = userData['deptIds'] ?? [];
    //   userDepts.add(v.id);
    //   await userRef.doc(uid).update({'deptIds': userDepts});
    //   // move above logic to cloud function
    //   // return []; - this return will be in the next 'then'
    // }).then((_) {
    //   setState(() {
    //     addMemberLoading = false;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Member added.'),
    //     ),
    //   );
    // });
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

  void refreshDeptModel() async {
    departmentModel =
        DeptModel.fromSnapshot(await deptRef.doc(departmentModel.id).get());
    userController.user.userDepts
        .removeWhere((dModel) => dModel.id == departmentModel.id);
    userController.user.userDepts.add(departmentModel);
    Get.off(DeptScreen(departmentModel));
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // var platform = Theme.of(context).platform;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            departmentModel.name + ' (${departmentModel.hospShortName})',
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          ),
        ),
        drawer: LeadingDrawer(departmentModel.id),
        backgroundColor: Colors.white,
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth:
                      ResponsiveWidget.isSmallScreen(context) ? 340 : 400),
              child: ListView(
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text('Refresh'),
                        // need to disable button on refresh
                        onPressed: () {
                          departmentModel.wardsInitialised = false;
                          departmentModel.membersInitialised = false;
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  Center(
                    child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Color(0xffdadada),
                        backgroundImage:
                            NetworkImage(departmentModel.imageUrl)),
                  ),
                  CenterBoldText(departmentModel.name),
                  CenterBoldText(' (${departmentModel.hospShortName})'),

                  // if (isWebMobile && isMember)
                  //   SizedBox(
                  //     height: 10,
                  //   ),
                  // if (isMember)
                  //   FutureBuilder(
                  //     future: iniWards(),
                  //     builder: (BuildContext context,
                  //         AsyncSnapshot<dynamic> snapshot) {
                  //       if (snapshot.connectionState ==
                  //           ConnectionState.done) {
                  //         return Column(
                  //           children: [
                  //             ExpansionTile(
                  //               title: Text('Wards'),
                  //               subtitle: Text(dmwm.length.toString()),
                  //               children: dmwm.length > 0
                  //                   ? dmwm
                  //                       .map((wm) => ListTile(
                  //                           title: new Text(wm.name),
                  //                           onTap: () =>
                  //                               Get.to(WardScreen(wm))))
                  //                       .toList()
                  //                   : [],
                  //               initiallyExpanded: true,
                  //             ),
                  //             // SizedBox(
                  //             //   height: 10,
                  //             // ),
                  //             // ExpansionTile(
                  //             //   title: Text('Peri Pts'),
                  //             //   subtitle: Text(departmentModel.lpwpm.length
                  //             //       .toString()),
                  //             //   children: departmentModel.lpwpm.length > 0
                  //             //       ? departmentModel.lpwpm
                  //             //           .map((wpm) => ListTile(
                  //             //                 title: new Text(wpm.name),
                  //             //                 // onTap: () =>
                  //             //                 //     Get.to(WardScreen(wm))
                  //             //                 trailing: Text(
                  //             //                     wpm.wardId.isNotEmpty
                  //             //                         ? 'Cur-Ad'
                  //             //                         : ''),
                  //             //               ))
                  //             //           .toList()
                  //             //       : [],
                  //             //   initiallyExpanded: true,
                  //             // ),
                  //           ],
                  //         );
                  //       } else {
                  //         return CircularProgressIndicator();
                  //       }
                  //     },
                  //   )
                  // else
                  //   Text('Request for Department Membership to view Wards'),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // Divider(
                  //   color: Colors.purple,
                  //   thickness: 3,
                  // ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // FutureBuilder(
                  //   future: iniMembers(),
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<dynamic> snapshot) {
                  //     if (snapshot.connectionState ==
                  //         ConnectionState.done) {
                  //       return Theme(
                  //           data: Theme.of(context).copyWith(
                  //               dividerTheme: DividerThemeData(
                  //                   color: Colors.transparent,
                  //                   thickness: 3.5)),
                  //           child: ExpansionTile(
                  //             title: Text('leijin'),
                  //             subtitle: Text(dmmm.length.toString()),
                  //             children: dmmm.length > 0
                  //                 ? dmmm
                  //                     .map((mm) => ListTile(
                  //                           title: new Text(mm.name),
                  //                           leading: CircleAvatar(
                  //                             backgroundImage:
                  //                                 NetworkImage(mm.imageUrl),
                  //                           ),
                  //                         ))
                  //                     .toList()
                  //                 : [],
                  //             initiallyExpanded: false,
                  //           ));
                  //     } else {
                  //       return CircularProgressIndicator();
                  //     }
                  //   },
                  // ),

                  // ============================================================
                  SizedBox(height: 10),
                  ExpansionPanelList
                      .radio(dividerColor: Colors.blue, children: [
                    ExpansionPanelRadio(
                        value: 'ward',
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            )),
                            leading: Icon(Icons.other_houses),
                            title: BoldButtonText('Wards'),
                            tileColor: isExpanded ? Colors.blue : Colors.white,
                          );
                        },
                        body: !isMember
                            ? Text(
                                'Request for Department Membership to view Wards')
                            : FutureBuilder(
                                future: iniWards(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Column(
                                      children: dmwm.length > 0
                                          ? dmwm
                                              .map((wm) => ListTile(
                                                    title: new Text(wm.name),
                                                    onTap: () =>
                                                        Get.to(WardScreen(wm)),
                                                    leading: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              wm.imageUrl),
                                                    ),
                                                  ))
                                              .toList()
                                          : [],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              )),
                    ExpansionPanelRadio(
                        value: 'member',
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            )),
                            leading: Icon(Icons.person),
                            title: BoldButtonText('Dept Members'),
                            tileColor: isExpanded ? Colors.blue : Colors.white,
                          );
                        },
                        body: FutureBuilder(
                          future: iniMembers(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Column(
                                children: dmmm.length > 0
                                    ? dmmm
                                        .map((mm) => ListTile(
                                              title: new Text(mm.name),
                                              // onTap: () =>
                                              //     Get.to(MemberScreen(mm)),
                                              leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      mm.imageUrl)),
                                            ))
                                        .toList()
                                    : [],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        )),
                  ]),
                  SizedBox(height: 17),
                  if (isMember)
                    ElevatedButton.icon(
                      icon: Icon(Icons.other_houses),
                      label: BoldButtonText('Add Ward'),
                      onPressed: () async {
                        Get.to(AsWardScreen(departmentModel));
                        // below line - why is it future?
                        // Navigator.pushNamed(
                        //   context,
                        //   '/as_ward',
                        // );
                        // if (wardId != null) getDept(); - just refresh after that lah
                      },
                    ),
                  // add text shortcut here
                  if (isMember)
                    ElevatedButton.icon(
                      icon: Icon(Icons.local_hospital),
                      label: BoldButtonText('Add Clinic'),
                      onPressed: () {},
                    ),
                  if (isMember)
                    ElevatedButton.icon(
                      icon: Icon(Icons.abc),
                      label: BoldButtonText('Add Shorthands'),
                      onPressed: () {},
                    ),
                  if (isMember && (isWebMobile || isApp))
                    if (addMemberLoading)
                      CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        icon: Icon(Icons.qr_code_scanner),
                        label: BoldButtonText('Add Dept Member'),
                        // ElevatedButton(
                        //   child: RichText(
                        //     text: TextSpan(
                        //       children: [
                        //         WidgetSpan(
                        //             child: Icon(Icons.qr_code_scanner),
                        //             style: TextStyle(fontSize: 18)),
                        //         TextSpan(text: ' Add Member'),
                        //       ],
                        //     ),
                        //   ),
                        onPressed: () async {
                          String? memberId =
                              await Navigator.of(context).push<String>(
                            MaterialPageRoute(
                              builder: (c) {
                                return QrView('Scan colleague\s QR code');
                              },
                            ),
                          );
                          // await Get.to(QrCameraScreen(
                          //     'Scan colleage\'s profile QR code'));

                          // final String? memberId =
                          //     await Navigator.of(context).push<String>(
                          //   MaterialPageRoute(
                          //     builder: (c) {
                          //       return QrCameraScreen(
                          //           'Add member by scanning user\'s profile QR code');
                          //     },
                          //   ),
                          // );
                          if (departmentModel.members.contains(memberId)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Already a member of department.'),
                              ),
                            );
                          } else {
                            addMember(memberId!);
                          }
                        },
                      ),
                ],
              ),
            ),
          ),
        ));
  }
}

// FutureBuilder<QuerySnapshot>(
//     future: wardRef
//         .where('deptId', isEqualTo: widget.deptId)
//         .get(), //get hosp from cache and save last updated time in sqflite
//     builder: (BuildContext context,
//         AsyncSnapshot<QuerySnapshot> wardsnapshot) {
//       if (wardsnapshot.connectionState ==
//           ConnectionState.done) {
//         if (wardsnapshot.data != null) {
//           var wards = wardsnapshot.data.docs
//               .map((DocumentSnapshot document) {
//             Map<String, dynamic> ward = document.data();
//             return new ListTile(
//                 title: new Text(ward['name']),
//                 onTap: () =>
//                     // Navigator.pushNamed(
//                     //   context,
//                     //   '/ward',
//                     //   arguments:
//                     //       WardScreenArguments(document.id),
//                     // ),
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (c) {
//                           return WardScreen(document.id);
//                         },
//                       ),
//                     ));
//           }).toList();
//           return
//       ;
//     } else {
//       return ExpansionTile(
//         title: Text('Wards'),
//         subtitle: Text(0.toString()),
//       );
//     }
//   } else {
//     return ExpansionTile(
//       title: Text('Wards'),
//       subtitle: CircularProgressIndicator(),
//     );
//   }
// })
// FutureBuilder<QuerySnapshot>(
//     future: userRef.where('deptIds', arrayContainsAny: [
//       widget.deptId
//     ]).get(), //get hosp from cache and save last updated time in sqflite
//     builder: (BuildContext context,
//         AsyncSnapshot<QuerySnapshot> usersnapshot) {
//       if (usersnapshot.connectionState ==
//           ConnectionState.done) {
//         if (usersnapshot.data != null) {
//           var users = usersnapshot.data.docs
//               .map((DocumentSnapshot document) {
//             Map<String, dynamic> user = document.data();
//             return new ListTile(
//               leading: CircleAvatar(
//                 backgroundImage:
//                     NetworkImage(user['imageUrl']),
//                 backgroundColor: Colors.grey,
//               ),
//               title: new Text(user['name']),
//             );
//           }).toList();
//           return
//       ;
//     } else {
//       return ExpansionTile(
//         title: Text('Members'),
//         subtitle: Text(0.toString()),
//         initiallyExpanded: true,
//       );
//     }
//   } else {
//     return ExpansionTile(
//       title: Text('Members'),
//       subtitle: CircularProgressIndicator(),
//       initiallyExpanded: true,
//     );
//   }
// }),
// deptRef.doc(args.deptId).get().then((v) {
// Navigator.pushReplacementNamed(
//   context,
//   '/dept',
//   arguments: DeptScreenArguments(args.deptId),
// );
// });

// Navigator.of(context).pushReplacement(
//   MaterialPageRoute(
//     builder: (c) {
//       return DeptScreen(widget.deptId);
//     },
//   ),
// );

// Get.off(DeptScreen(departmentId, departmentModel));
