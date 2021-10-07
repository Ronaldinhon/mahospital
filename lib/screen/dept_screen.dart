import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/models/user.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/screen/qr_camera_screen.dart';
import 'package:mahospital/screen/ward_screen.dart';
// import '/screen/as_ward_screen.dart';
// import '/screen/ward_screen.dart';
import '/widget/leading_drawer.dart';

// import '../qr_view.dart';

class DeptScreen extends StatefulWidget {
  final String deptId;
  final DeptModel deptModel;

  DeptScreen(this.deptId, this.deptModel);
  @override
  _DeptScreenState createState() => _DeptScreenState();
}

class _DeptScreenState extends State<DeptScreen> {
  late String departmentId;
  late String uid;
  late DeptModel departmentModel;
  late List<UserModel> dmmm; //deptModelMemberModel
  late List<WardModel> dmwm; //deptModelWardModel
  bool addMemberLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    departmentId = widget.deptId;
    departmentModel = widget.deptModel;

    dmmm = departmentModel.memberModels;
    dmwm = departmentModel.wardModels;
    super.initState();
  }

  void addMember(String userId) async {
    setState(() {
      addMemberLoading = true;
    });
    await deptPermRef.add({
      'deptId': departmentId,
      'userId': userId,
      'authBy': uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }).then((DocumentReference<Object?> v) async {
      DocumentSnapshot<Object?> deptLatest =
          await deptRef.doc(departmentId).get();
      List mem = deptLatest['members'];
      mem.add(userId);
      deptRef.doc(departmentId).update(
          {'members': mem, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
      final DocumentSnapshot<Object?> userData = await userRef.doc(uid).get();
      List userDepts = userData['deptIds'] ?? [];
      userDepts.add(v.id);
      await userRef.doc(uid).update({'deptIds': userDepts});
      // move above logic to cloud function
      // return []; - this return will be in the next 'then'
    }).then((_) {
      setState(() {
        addMemberLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member added.'),
        ),
      );
    });
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
        DeptModel.fromSnapshot(await deptRef.doc(departmentId).get());
    userController.user.userDepts
        .removeWhere((dModel) => dModel.id == departmentId);
    userController.user.userDepts.add(departmentModel);
    Get.off(DeptScreen(departmentModel.id, departmentModel));
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            departmentModel.name,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          ),
        ),
        drawer: LeadingDrawer(departmentId),
        backgroundColor: Theme.of(context).primaryColor,
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            child: Text('Refresh'),
                            // need to disable button on refresh
                            onPressed: () => refreshDeptModel(),
                          )
                        ],
                      ),
                      CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xffdadada),
                          backgroundImage:
                              NetworkImage(departmentModel.imageUrl)),
                      SizedBox(
                        height: 15,
                      ),
                      // ElevatedButton(
                      //   child: Text('Add Ward'),
                      //   onPressed: () async {
                      //     // below line - why is it future?
                      //     // final Future<String> wardId =
                      //     // final wardId =
                      //     Navigator.pushNamed(
                      //       context,
                      //       '/as_ward',
                      //       arguments: AsWardScreenArguments(
                      //         snapshot.data.id,
                      //         dept['name'],
                      //         dept['shortName'],
                      //         dept['hospId'],
                      //       ),
                      //     );
                      //     // if (wardId != null) getDept(); - just refresh after that lah
                      //   },
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      if (isWebMobile && departmentModel.members.contains(uid))
                        if (addMemberLoading)
                          CircularProgressIndicator()
                        else
                          ElevatedButton(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                      child: Icon(Icons.qr_code_scanner),
                                      style: TextStyle(fontSize: 25)),
                                  TextSpan(text: ' Add Member'),
                                ],
                              ),
                            ),
                            onPressed: () async {
                              String memberId = await Get.to(QrCameraScreen(
                                  'Add member by scanning user\'s profile QR code'));
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
                                    content: Text('Already a member of dept.'),
                                  ),
                                );
                              } else {
                                addMember(memberId);
                              }
                            },
                          ),
                      if (isWebMobile && departmentModel.members.contains(uid))
                        SizedBox(
                          height: 10,
                        ),
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
                      ExpansionTile(
                        title: Text('Wards'),
                        subtitle: Text(dmwm.length.toString()),
                        children: dmwm.length > 0
                            ? dmwm
                                .map((wm) => ListTile(
                                    title: new Text(wm.name),
                                    onTap: () => Get.to(WardScreen(wm))))
                                .toList()
                            : [],
                        initiallyExpanded: true,
                      )
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
                      ,
                      SizedBox(
                        height: 10,
                      ),
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
                      ExpansionTile(
                        title: Text('Members'),
                        subtitle: Text(dmmm.length.toString()),
                        children: dmmm.length > 0
                            ? dmmm
                                .map((mm) => ListTile(
                                      title: new Text(mm.name),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(mm.imageUrl),
                                      ),
                                    ))
                                .toList()
                            : [],
                        initiallyExpanded: false,
                      )
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

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
