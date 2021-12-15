import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/models/hosp_model.dart';
import '/screen/dept_screen.dart';
import '/widget/leading_drawer.dart';

import 'as_dept_screen.dart';

class HospScreen extends StatefulWidget {
  final HospModel hosp;
  HospScreen(this.hosp);
  @override
  _HospScreenState createState() => _HospScreenState();
}

class _HospScreenState extends State<HospScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late HospModel hospital;

  @override
  void initState() {
    hospital = widget.hosp;
    super.initState();
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

  void refreshHosp() async {
    var hnm = await hospListController.refreshHospModel(hospital.id);
    // var st = hnm.getDeptList();
    Get.off(HospScreen(hnm));
  }

  Future<List<DeptModel>> getDeptFirst() {
    return hospital.getDeptList();
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: getDeptFirst(),
    //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            hospital.name,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          ),
        ),
        drawer: LeadingDrawer('_'),
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
                            onPressed: () {
                              // refreshHosp();
                              setState(() {});
                            }
                            // hospRef.doc(args.hospId).get().then((v) {
                            /* above line only useful when updated time is recorded or 
                                         in this case not very useful if user refreshes repeatedly? */
                            // Navigator.pushReplacementNamed(
                            //   context,
                            //   '/hosp',
                            //   arguments: HospScreenArguments(widget.hospId),
                            // );
                            // Navigator.of(context).pushReplacement(
                            //   MaterialPageRoute(
                            //     builder: (c) {
                            //       return HospScreen(widget.hospId);
                            //     },
                            //   ),
                            // );
                            // });
                            ,
                          )
                        ],
                      ),
                      CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xffdadada),
                          backgroundImage: NetworkImage(hospital.imageUrl)),
                      SizedBox(
                        height: 15,
                      ),
                      Text("Address: ${hospital.address}"),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        child: Text('Add Department'),
                        onPressed: () {
                          Get.to(AsDeptScreen(hospital));
                          // Navigator.pushNamed(
                          //   context,
                          //   '/as_dept',
                          //   arguments: AsDeptScreenArguments(snapshot.data.id,
                          //       hospi['name'], hospi['shortName']),
                          // );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FutureBuilder(
                        future: getDeptFirst(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return hospital.deptModels.isEmpty
                                ? ExpansionTile(
                                    title: Text('Departments'),
                                    subtitle: Text(0.toString()),
                                  )
                                : ExpansionTile(
                                    title: Text('Departments'),
                                    subtitle: Text(
                                        hospital.deptModels.length.toString()),
                                    children: hospital.deptModels
                                        .map((dm) => ListTile(
                                              title: new Text(dm.name),
                                              onTap: () => Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (c) {
                                                    return DeptScreen(dm);
                                                  },
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      )
                      // if (deptsnapshot.data != null) {
                      //   var depts = deptsnapshot.data.docs
                      //       .map((DocumentSnapshot document) {
                      //     Map<String, dynamic> dept = document.data();
                      //     return new ListTile(
                      //       title: new Text(dept['name']),
                      //       onTap: () =>
                      //           Navigator.of(context).pushReplacement(
                      //         MaterialPageRoute(
                      //           builder: (c) {
                      //             return DeptScreen(document.id);
                      //           },
                      //         ),
                      //       ),
                      //     );
                      //   }).toList();
                      //   return ExpansionTile(
                      //     title: Text('Departments'),
                      //     subtitle: Text(depts.length.toString()),
                      //     children: depts,
                      //   );
                      // } else {
                      //   return ;
                      // }
                      ,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
    //     } else {
    //       return CircularProgressIndicator();
    //     }
    //   },
    // );
  }
}
