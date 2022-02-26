import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/helpers/reponsiveness.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/screen/login_screen.dart';
import '/controllers/auth_controller.dart';
import '/screen/dept_screen.dart';

class LeadingDrawer extends StatefulWidget {
  final String currentPage;
  LeadingDrawer(this.currentPage);

  @override
  _LeadingDrawerState createState() => _LeadingDrawerState();
}

class _LeadingDrawerState extends State<LeadingDrawer> {
  final AuthController ac = Get.find<AuthController>();
  late List<ListTile> deptTiles;
  @override
  void initState() {
    super.initState();
  }

  // Future<QuerySnapshot<Object>> getUserDept() async {
  //   QuerySnapshot<Object> deptObjs =
  //       await depts.where('members', arrayContainsAny: [user.uid]).get();
  //   return deptObjs;
  // }

  ListTile produceTile(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () =>
          widget.currentPage == route ? Get.back() : Get.offNamed('/' + route),
      tileColor: widget.currentPage == route
          ? Theme.of(context).primaryColorLight
          : null,
    );
  }

  ListTile deptTile(String title, String deptId, DeptModel dm) {
    return ListTile(
      title: Text(title),
      onTap: () => widget.currentPage == deptId //need change?
          ? Get.back()
          : Get.off(DeptScreen(dm), preventDuplicates: false),
      tileColor: widget.currentPage == deptId
          ? Theme.of(context).primaryColorLight
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width /
            (ResponsiveWidget.isSmallScreen(context)
                ? 1.5
                : ResponsiveWidget.isMediumScreen(context)
                    ? 3
                    : 5),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              ListTile(
                title: Text(
                  'Directory',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: Icon(
                  Icons.map,
                  color: Colors.black,
                ),
                tileColor: Theme.of(context).primaryColor,
              ),
              produceTile(context, 'Profile', 'profile'),
              !userController.user.verified
                  ? Container()
                  : produceTile(context, 'Add / Search Hospital', 'as_hosp'),
              FutureBuilder(
                future: userController.user.deptList(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return userController.user.verified
                        ? ExpansionTile(
                            title: Text('Departments'),
                            children: userController.user.userDepts
                                .map((d) => deptTile(
                                    '${d.shortName} (${d.hospShortName})',
                                    d.id,
                                    d))
                                .toList(),
                          )
                        : Container();
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              // Obx(() => ac.userModel.value.userDepts.forEach(f)),
              // FutureBuilder<QuerySnapshot<Object>>(
              //   future: getUserDept(),
              //   builder: (BuildContext context,
              //       AsyncSnapshot<QuerySnapshot<Object>> snapshot) {
              //     if (snapshot.connectionState == ConnectionState.done) {
              //       QuerySnapshot<Object> departments = snapshot.data;
              //       List<ListTile> deptTiles = [];
              //       if (departments.docs.isNotEmpty) {
              //         departments.docs.forEach((deptMap) async {
              //           var hosp = await hosps.doc(deptMap['hospId']).get();
              //           deptTiles.add(deptTile(
              //               '${deptMap['shortName']} (${hosp['shortName']})',
              //               deptMap.id));
              //         });
              //         return
              // ;

              //       } else {
              //         return Container();
              //       }

              //       // return deptTile.length > 0
              //       //     ? ExpansionTile(
              //       //         title: Text('Wards'),
              //       //         children: deptTile,
              //       //       )
              //       //     : Container();
              //     } else {
              //       return ListTile(
              //         title: CircularProgressIndicator(),
              //       );
              //     }
              //   },
              // ),

              // ListTile(
              //   title: Text('Realtime Testing page'),
              //   onTap: () => Navigator.of(context)
              //       .pushReplacementNamed('/realtime_test'),
              // ),

              ListTile(
                title: Text('Logout'),
                onTap: () {
                  auth.signOut();
                  Get.offAll(LoginScreen());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
