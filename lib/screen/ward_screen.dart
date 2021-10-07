import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';

import 'package:flutter/material.dart';
import 'package:mahospital/helpers/show_loading.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';
import '/widget/bed_list_tile.dart';
import 'as_bed_screen.dart';

class WardScreen extends StatefulWidget {
  final WardModel ward;

  WardScreen(this.ward);
  @override
  _WardScreenState createState() => _WardScreenState();
}

class _WardScreenState extends State<WardScreen> {
  // late String wardId;
  late DocumentSnapshot<Object?> ward;
  late List<BedModel> localBedModels;
  late List<WardPtModel> localWardPtModels;
  late List<BedListTile> bedTiles;
  late WardModel wardModel;

  List<WardPtModel> wpModels = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    wardModel = widget.ward;
    print(wardModel.bedIdList);
    super.initState();
  }

  Future<List<BedListTile>> getBedsForWS() async {
    // QuerySnapshot<Object?> st =
    //     await wardRef.doc(widget.wardId).get().then((qward) {
    //   ward = qward;
    //   bedIds = wardModel.bedIdList;
    //   return bedRef.where('wardId', isEqualTo: qward.id).get();
    // });
    // wardModel = widget.ward;
    localWardPtModels = await wardModel.getPts();
    if (wardModel.bedIdList.isNotEmpty) {
      var locodels = await wardModel.getBeds();
      localBedModels = locodels;
      // return createBedsList(locodels);
      return [];
    } else
      return [];
    // return localBedModels;
  }

  List<BedListTile> createBedsList(List<BedModel> bedModelList) {
    List<BedListTile> wBeds = [];
    if (bedModelList.isNotEmpty) {
      bedModelList.asMap().forEach((index, bedModel) {
        if (bedModel.active) {
          BedListTile bedTile = BedListTile(
            bedModel,
            index,
          );
          if (bedModel.ptId.isNotEmpty) wpModels.add(bedModel.wardPtModel);
          wBeds.add(bedTile);
        }
      });
      currentWardPtsListController.setCurrentPtsList(wpModels);
      // Provider.of<PtList>(context, listen: false).setList(ptIds);
    }
    return wBeds;
  }

  void updateWM() async {
    // update ward model
    showLoading();
    var wmFirebase = await wardRef.doc(wardModel.imageUrl).get();
    WardModel wm = WardModel.fromSnapshot(wmFirebase);
    DeptModel dept = userController.user.userDepts
        .firstWhere((dept) => dept.id == wm.deptId);
    dept.wardModels.removeWhere((owm) => owm.id == wm.id);
    dept.wardModels.add(wm);
    dismissLoadingWidget();
    Get.off(WardScreen(wm));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BedListTile>>(
        future: getBedsForWS(),
        builder:
            (BuildContext context, AsyncSnapshot<List<BedListTile>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot);
            return Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  title: Text('Ward (${wardModel.name})'),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                body: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Card(
                      margin: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            top: 15, bottom: 15, left: 15, right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    child: Text('Refresh'),
                                    onPressed: () => updateWM()
                                    // async {
                                    //   showLoading();

                                    //   Navigator.of(context).pushReplacement(
                                    //     MaterialPageRoute(
                                    //       builder: (c) {
                                    //         return WardScreen(widget.wardId);
                                    //       },
                                    //     ),
                                    //   );
                                    // },
                                    )
                              ],
                            ),
                            CircleAvatar(
                                radius: 45,
                                backgroundColor: Color(0xffdadada),
                                backgroundImage:
                                    NetworkImage(wardModel.imageUrl)),
                            SizedBox(
                              height: 8,
                            ),
                            Text("${wardModel.shortName}"),
                            Text("${wardModel.description}"),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Beds',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                  textAlign:
                                      TextAlign.left, //dunno got use or not
                                ),
                                SizedBox(width: 5),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => AsBedScreen(
                                    //           wardModel.id, localBedModels)),
                                    // );
                                  },
                                )
                              ],
                            ),
                            if (snapshot.data!.isNotEmpty)
                              SizedBox(
                                height: 5,
                              ),
                            if (snapshot.data!.isNotEmpty)
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 300),
                                child: ListView(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  children: <Widget>[...?snapshot.data],
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
