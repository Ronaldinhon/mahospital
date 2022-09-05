import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';

import 'package:flutter/material.dart';
import 'package:mahospital/helpers/reponsiveness.dart';
import 'package:mahospital/helpers/show_loading.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';
import '/widget/bed_list_tile.dart';
import 'as_bed_screen.dart';
import 'bed_screen.dart';
import 'pt_screen.dart';

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
  // late List<BedListTile> bedTiles;
  late WardModel wardModel;

  List<WardPtModel> wpModels = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    wardModel = widget.ward;
    currentWPLC.cwm.value = wardModel;
    currentWPLC.setPdfTheme();
    super.initState();
  }

  Future<List<BedExpansionTile>> getBedsForWS() async {
    // QuerySnapshot<Object?> st =
    //     await wardRef.doc(widget.wardId).get().then((qward) {
    //   ward = qward;
    //   bedIds = wardModel.bedIdList;
    //   return bedRef.where('wardId', isEqualTo: qward.id).get();
    // });
    // wardModel = widget.ward;

    // localWardPtModels = await wardModel.getPts(); // this 1 no need ba

    if (wardModel.bedIdList.isNotEmpty) {
      var locodels = await wardModel.getBeds(); // is already in sequence
      localBedModels = locodels;
      for (var lbm in localBedModels) {
        if (lbm.ptId.isNotEmpty) {
          await lbm.getPtModel();
        }
      }
      // localBedModels.forEach((bm) async {
      //   if (bm.ptId.isNotEmpty) {
      //     await bm.getPtModel();
      //   }
      // });
      return createBedsList(locodels);
    } else
      return [];
    // return localBedModels;
  }

  List<BedExpansionTile> createBedsList(List<BedModel> bedModelList) {
    // List<BedListTile> wBeds = [];
    List<BedExpansionTile> wBeds = [];
    if (bedModelList.isNotEmpty) {
      var prevWardPtId;
      bedModelList.asMap().forEach((index, bedModel) {
        if (bedModel.active) {
          if (bedModel.ptId.isNotEmpty) {
            wpModels.add(bedModel.wardPtModel);
            prevWardPtId = bedModel.ptId;
          }
          // BedListTile bedTile = BedListTile(
          //   bedModel,
          //   wardModel,
          //   index,
          //   prevWardPtId,
          // );
          // wBeds.add(bedTile);
          BedExpansionTile lkj = BedExpansionTile(
            bedModel.name,
            'Pt: ' +
                (bedModel.ptInitialised
                    ? bedModel.wardPtModel.ptDetails()
                    : '-'),
            false,
            () {
              print('hey');
              if (bedModel.ptInitialised) {
                currentWPLC.cbm.value = bedModel;
                currentWPLC.cwpm.value = bedModel.wardPtModel;
                currentWPLC.updatePtDetailsConts(bedModel.wardPtModel);
              }

              bedModel.ptInitialised
                  ? Get.to(PtScreen())
                  : !bedModel.error
                      ? Get.to(BedScreen(bedModel, wardModel))
                      : Get.snackbar(
                          "Error retrieving patient data",
                          'Please refresh ward page.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                        );
            },
          );
          wBeds.add(lkj);
        }
      });
      currentWPLC.setCurrentPtsList(wpModels);
      // Provider.of<PtList>(context, listen: false).setList(ptIds);
    }
    return wBeds;
  }

  void updateWM() async {
    // update ward model - or maybe just use setState and getBedsForWS() again next time
    showLoading();
    var wmFirebase = await wardRef.doc(wardModel.id).get();
    WardModel wm = WardModel.fromSnapshot(wmFirebase);
    DeptModel dept = userController.user.userDepts
        .firstWhere((dept) => dept.id == wm.deptId);
    dept.wardModels.removeWhere((owm) => owm.id == wm.id);
    dept.wardModels.add(wm);
    dismissLoadingWidget();
    Get.off(WardScreen(wm), preventDuplicates: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Ward (${wardModel.name})'),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              ExpansionTile(
                title: Text('Ward Details',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xffdadada),
                      backgroundImage: NetworkImage(wardModel.imageUrl)),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text("${wardModel.shortName}"),
                          Text("${wardModel.description}"),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {},
                      )
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 20),
                  Text(
                    'Beds',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    textAlign: TextAlign.left, //dunno got use or not
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Get.to(BedScreen(wardModel));
                      Get.to(AsBedScreen(wardModel));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.print),
                    onPressed: () {}, // goes to another page
                  ),
                ],
              ),

              SizedBox(
                height: 5,
              ),
              // ConstrainedBox(
              //     constraints: BoxConstraints(maxHeight: 300),
              //     child: GridView(
              //       gridDelegate:
              //           SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount:
              //             ResponsiveWidget.isSmallScreen(context)
              //                 ? 2
              //                 : 3,
              //       ),
              //       children: <Widget>[...?snapshot.data],
              //     ))
              FutureBuilder<List<BedExpansionTile>>(
                  future: getBedsForWS(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<BedExpansionTile>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Expanded(
                          flex: 1,
                          child: ListView(
                            shrinkWrap: true,
                            children: snapshot.data!,
                          ));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  })
              // if (snapshot.data!.isNotEmpty)
            ],
          ),
        ),
      ),
    );
  }
}

class BedExpansionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool checked;
  final void Function() checkFn;
  // final vslist = ['HR', 'SYS', 'DIA', 'RR', 'O2', 'Temp', 'Notes'].asMap().forEach((i, v) => vsList.add(
  //       VsTextField(v, sendDataMap, saveData, i == (vitalsTitle.length - 1))));

  BedExpansionTile(this.title, this.subtitle, this.checked, this.checkFn);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: checked
                ? Icon(Icons.check_box, size: 20)
                : Icon(Icons.check_box_outline_blank, size: 20),
            onTap: () => print(ecController.asdljk),
          ),
          SizedBox(width: 10),
          GestureDetector(
            child: Icon(Icons.file_open, size: 20),
            onTap: checkFn,
          ),
        ],
      ),
      children: [
        SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 120,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6),
            reverse: false,
            child: TextFormField(
              key: ValueKey('diagnosis'),
              // controller: currentWPLC.cpCurDiag,
              // onChanged: (yes) => ecController.checkOnChange(),
              initialValue:
                  'lkj \nasd \nlkj \nasdlkj \nasdlkj \nasdlkj \nasdlkj \nasdlkj \nasd \nasdlkj \nasd',
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  labelText: 'Diagnosis',
                  contentPadding: const EdgeInsets.all(4.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {},
                  )),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
        SizedBox(height: 20),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 120,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6),
            reverse: false,
            child: TextFormField(
              key: ValueKey('plan'),
              // controller: currentWPLC.cpCurPlan,
              // onChanged: (yes) => ecController.checkOnChange(),
              initialValue:
                  'lkj \nasd \nlkj \nasdlkj \nasdlkj \nasdlkj \nasdlkj \nasdlkj \nasd \nasdlkj \nasd',
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  labelText: 'Plan',
                  contentPadding: const EdgeInsets.all(4.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {},
                  )),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ConstrainedBox(
          constraints: new BoxConstraints(
            maxHeight: 200,
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: TextFormField(
              // focusNode: focusNode,
              // controller: controller,
              // onEditingComplete: onEditingComplete,
              key: ValueKey('entry'),
              onChanged: (yes) {
                ecController.checkOnChange();
              },
              validator: (val) {
                if (val!.trim().isEmpty) {
                  return 'Review/Entry cannot be empty!';
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: 'Review / Entry',
                  contentPadding: const EdgeInsets.all(4.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {},
                  )),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(top: 7, left: 5, right: 5, bottom: 4),
                      width: 120,
                      child: TextFormField(
                        key: ValueKey('date'),
                        // controller: dobCont,
                        // validator:
                        //     RequiredValidator(errorText: 'Date is required'),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () {} //_selectDate(context),
                              ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            top: 7, left: 5, right: 5, bottom: 4),
                        width: 120,
                        child: TextFormField(
                          key: ValueKey('time'),
                          // controller: timeCont,
                          // validator:
                          //     RequiredValidator(errorText: 'Time is required'),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Time',
                            suffixIcon: IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () {} // => _selectTime(context),
                                ),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                          ),
                        )),
                    // ...vsList
                  ],
                ),
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
