import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
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
import '../tabs/vs_table.dart';
import '/widget/bed_list_tile.dart';
import 'as_bed_screen.dart';
import 'bed_screen.dart';
import 'pt_screen.dart';
import 'package:intl/intl.dart';

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
  final yourScrollController = ScrollController();
  final yourScrollController1 = ScrollController();
  TextEditingController tec = TextEditingController();
  late Future<List<BedModel>> gbfws;
  List<String> masterBedIdList = [];
  String masterBedId = '';

  @override
  void initState() {
    wardModel = widget.ward;
    currentWPLC.cwm.value = wardModel;
    currentWPLC.setPdfTheme();

    ecController.vitalsTitle.keys
        .toList()
        .getRange(0, 6)
        .forEach((v) => vsList.add(VsTextField(v, sendDataMap, saveData)));

    ecController.bloodResMap
        .forEach((k, v) => bloodRestList.add(BloodResTextField(k)));

    gbfws = getBedsForWS();
    super.initState();
  }

  // Future<List<BedExpansionTile>> getBedsForWS() async {
  // QuerySnapshot<Object?> st =
  //     await wardRef.doc(widget.wardId).get().then((qward) {
  //   ward = qward;
  //   bedIds = wardModel.bedIdList;
  //   return bedRef.where('wardId', isEqualTo: qward.id).get();
  // });
  // wardModel = widget.ward;

  // localWardPtModels = await wardModel.getPts(); // this 1 no need ba
  Future<List<BedModel>> getBedsForWS() async {
    if (wardModel.bedIdList.isNotEmpty) {
      // var locodels = await wardModel.getBeds(); // is already in sequence
      // print(locodels);
      // localBedModels = locodels;
      localBedModels = await wardModel.getBeds();
      for (var lbm in localBedModels) {
        if (lbm.ptId.isNotEmpty) {
          await lbm.getPtModel();
        }
      }
      // return createBedsList(locodels);
      return localBedModels;
    } else
      return [];
    // return localBedModels;
  }

  // List<BedExpansionTile> createBedsList(List<BedModel> bedModelList) {
  //   // List<BedListTile> wBeds = [];
  //   List<BedExpansionTile> wBeds = [];
  //   if (bedModelList.isNotEmpty) {
  //     var prevWardPtId;
  //     bedModelList.asMap().forEach((index, bedModel) {
  //       if (bedModel.active) {
  //         if (bedModel.ptId.isNotEmpty) {
  //           wpModels.add(bedModel.wardPtModel);
  //           prevWardPtId = bedModel.ptId;
  //         }
  //         BedExpansionTile lkj = BedExpansionTile(
  //           bedModel.name,
  //           'Pt: ' +
  //               (bedModel.ptInitialised
  //                   ? bedModel.wardPtModel.ptDetails()
  //                   : '-'),
  //           false,
  //           () {
  //             print('hey');
  //             if (bedModel.ptInitialised) {
  //               currentWPLC.cbm.value = bedModel;
  //               currentWPLC.cwpm.value = bedModel.wardPtModel;
  //               currentWPLC.updatePtDetailsConts(bedModel.wardPtModel);
  //             }

  //             bedModel.ptInitialised
  //                 ? Get.to(PtScreen())
  //                 : !bedModel.error
  //                     ? Get.to(BedScreen(bedModel, wardModel))
  //                     : Get.snackbar(
  //                         "Error retrieving patient data",
  //                         'Please refresh ward page.',
  //                         snackPosition: SnackPosition.BOTTOM,
  //                         backgroundColor: Colors.red,
  //                       );
  //           },
  //         );
  //         wBeds.add(lkj);
  //       }
  //     });
  //     currentWPLC.setCurrentPtsList(wpModels);
  //     // Provider.of<PtList>(context, listen: false).setList(ptIds);
  //   }
  //   return wBeds;
  // }

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

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final dobCont = TextEditingController();
  final timeCont = TextEditingController();
  List<VsTextField> vsList = [];
  List<BloodResTextField> bloodRestList = [];
  Map sendDataMap = {};
  void saveData() {}
  String ptId = '';

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        // print(DateFormat('dd/MM/yyyy').format(picked));
        dobCont.text = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedS = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedS != null && pickedS != selectedTime)
      setState(() {
        selectedTime = pickedS;
        // print(pickedS.format(context));
        timeCont.text = pickedS.format(context);
        // pickedS.hour.toString() + ':' + pickedS.minute.toString();
      });
  }

  // rmb to change editid everytime - no need ba,
  // if not everytime open new pt need to notify, idk how to do that also
  String addEditInt = '0';
  Future<String> setupDx(String ptId) async {
    // later create otherDx
    // and rmb to clear controller everytime change pt
    ecController.dxCont.text = ptId;
    return ptId;
  }

  Future<String> setupPlan(String ptId) async {
    // later create otherDx
    ecController.planCont.text = ptId;
    return ptId;
  }

  Future<String> setupDrug(String ptId) async {
    // later create otherDx
    ecController.drugCont.text = ptId;
    return ptId;
  }

  Future<void> clearEntry() async {
    // print('called');
    ecController.entryCont.clear();
  }

  Future<void> clearVS() async {
    ecController.vitalsTitle.updateAll((name, value) => value = '');
  }

  Future<void> clearBR() async {
    ecController.bloodResMap.updateAll((name, value) => value = '');
  }

  Widget case2(String selectedOption, String ptId) {
    Map<String, Widget> hmm = {
      '0': FutureBuilder<void>(
        key: Key(ptId),
        future: clearEntry(),
        builder: (ctx, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              TextField(
                  controller: ecController.entryCont,
                  onChanged: (val) => print(ecController.entryCont.text),
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Entry',
                    // empty. Need to enable like, directed to medical dept message?
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all()),
                  child: IconButton(
                    onPressed: () {},
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  )),
            ],
          );
        },
      ),
      '1': FutureBuilder<String>(
        key: Key(ptId),
        future: setupDx(ptId),
        builder: (ctx, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              TextField(
                  maxLines: 4,
                  minLines: 2,
                  readOnly: true,
                  controller: TextEditingController(text: 'this\nthis\nthat'),
                  // controller: ecController.otherDxCont,
                  decoration: InputDecoration(
                    labelText: 'Other Dx', // pre-filled, by dept
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              SizedBox(height: 7),
              Container(
                constraints: BoxConstraints(maxHeight: 110),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child:
                    // Scrollbar(
                    //   thumbVisibility: true,
                    //   scrollbarOrientation: ScrollbarOrientation.right,
                    //   thickness: 5,
                    //   controller: yourScrollController1,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 7.0),
                    //     child:
                    Material(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    controller: yourScrollController1,
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: Text(ecController.dxCont.text),
                        leading: Icon(Icons.delete, color: Colors.red),
                        trailing: Icon(Icons.copy, color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      ListTile(
                        title: Text(ecController.dxCont.text),
                        leading: Icon(Icons.delete, color: Colors.red),
                        trailing: Icon(Icons.copy, color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      ListTile(
                        title: Text(ecController.dxCont.text +
                            ecController.dxCont.text +
                            ecController.dxCont.text +
                            ecController.dxCont.text),
                        leading: Icon(Icons.delete, color: Colors.red),
                        trailing: Icon(Icons.copy, color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                //   ),
                // ),
              ),
              TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: ecController.dxCont,
                  decoration: InputDecoration(
                    labelText:
                        '(this dept name short) Dx', // pre-filled, by dept
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all()),
                  child: IconButton(
                    onPressed: () {},
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  )),
            ],
          );
        },
      ),
      '2': FutureBuilder<String>(
        key: Key(ptId),
        future: setupPlan(ptId),
        builder: (ctx, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              TextField(
                  maxLines: 4,
                  minLines: 2,
                  readOnly: true,
                  controller: TextEditingController(text: 'this\nthis\nthat'),
                  // controller: ecController.otherPlanCont,
                  decoration: InputDecoration(
                    labelText: 'Other Plan', // pre-filled, by dept
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              SizedBox(height: 7),
              TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: ecController.planCont,
                  decoration: InputDecoration(
                    labelText:
                        '(this dept name short) Plan', // pre-filled, by dept
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all()),
                  child: IconButton(
                    onPressed: () {},
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  )),
            ],
          );
        },
      ),
      '3': FutureBuilder<String>(
        key: Key(ptId),
        future: setupDrug(ptId),
        builder: (ctx, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5),
              TextField(
                  maxLines: 4,
                  minLines: 2,
                  readOnly: true,
                  controller: TextEditingController(text: 'this\nthis\nthat'),
                  // controller: ecController.otherDrugCont,
                  decoration: InputDecoration(
                    labelText: 'Other Drug', // pre-filled, by dept
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              SizedBox(height: 7),
              TextField(
                  maxLines: 5,
                  // spellCheckConfiguration:,
                  controller: ecController.drugCont,
                  decoration: InputDecoration(
                    labelText:
                        '(this dept name short) Drug', // pre-filled, by dept
                    // Need to enable like, directed to medical dept message? - this 1 in entry ba
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                  )),
              Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all()),
                  child: IconButton(
                    onPressed: () {},
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  )),
            ],
          );
        },
      ),
      '4': FutureBuilder<void>(
        key: Key(ptId),
        future: clearVS(),
        builder: (ctx, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Vital Signs'),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Scrollbar(
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: 7, left: 5, right: 5, bottom: 4),
                            width: 180,
                            child: TextFormField(
                              key: ValueKey('date'),
                              controller: dobCont,
                              readOnly: true,
                              validator: RequiredValidator(
                                  errorText: 'Date is required'),
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Date',
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () => _selectDate(context),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                  top: 7, left: 5, right: 5, bottom: 4),
                              width: 160,
                              child: TextFormField(
                                key: ValueKey('time'),
                                controller: timeCont,
                                readOnly: true,
                                validator: RequiredValidator(
                                    errorText: 'Time is required'),
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: 'Time',
                                  prefixIcon: IconButton(
                                    icon: Icon(Icons.access_time),
                                    onPressed: () => _selectTime(context),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                ),
                              )),
                          ...vsList,
                          Container(
                            padding: EdgeInsets.only(
                                top: 7, left: 5, right: 5, bottom: 4),
                            width: 200,
                            child: TextFormField(
                              maxLines: 1,
                              maxLength: 70,
                              initialValue: ecController.vitalsTitle['Notes']!,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                labelText: 'Notes',
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all()),
                  child: IconButton(
                    onPressed: () {},
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  )),
            ],
          );
        },
      ),
      '5': FutureBuilder<void>(
        key: Key(ptId),
        future: clearBR(),
        builder: (ctx, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Blood Results'),
              Container(
                height: 55,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Scrollbar(
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: 7, left: 5, right: 5, bottom: 4),
                            width: 180,
                            child: TextFormField(
                              key: ValueKey('date'),
                              controller: dobCont,
                              readOnly: true,
                              validator: RequiredValidator(
                                  errorText: 'Date is required'),
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Date',
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: () => _selectDate(context),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                  top: 7, left: 5, right: 5, bottom: 4),
                              width: 160,
                              child: TextFormField(
                                key: ValueKey('time'),
                                controller: timeCont,
                                readOnly: true,
                                validator: RequiredValidator(
                                    errorText: 'Time is required'),
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText: 'Time',
                                  prefixIcon: IconButton(
                                    icon: Icon(Icons.access_time),
                                    onPressed: () => _selectTime(context),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                  ),
                                ),
                              )),
                          Container(
                            padding: EdgeInsets.only(
                                top: 7, left: 5, right: 5, bottom: 4),
                            width: 200,
                            child: TextFormField(
                              maxLines: 1,
                              maxLength: 70,
                              initialValue: ecController.bloodResMap['Notes']!,
                              // flutter doesnt check map keys haha
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 1.0),
                                ),
                                labelText: 'Notes',
                              ),
                            ),
                          ),
                          ...bloodRestList,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                      border: Border.all()),
                  child: IconButton(
                    onPressed: () {},
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    icon: Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                  )),
            ],
          );
        },
      ),
    };
    return hmm[selectedOption]!;
  }

  // RadioListTile<String>
  Container createRLT(String index) {
    String text = '';
    switch (index) {
      case '0':
        text = 'Entry';
        // empty - have to add in place of entry recorded (place_id, name, year)
        break;
      case '1':
        text = 'Diagnosis'; // by dept
        break;
      case '2':
        text = 'Plan'; // by dept
        break;
      case '3':
        text = 'Drugs';
        // by dept - in the same list (discipline followed by hosp name - shortForm)
        break;
      case '4':
        text = 'Vital Signs'; // empty
        break;
      case '5':
        text = 'Blood Results'; // empty
        break;
      default:
        text = 'Entry';
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          )),
      width: 150,
      child: RadioListTile<String>(
        selected: addEditInt == index,
        title: Text(text),
        value: index,
        groupValue: addEditInt,
        dense: true,
        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
        onChanged: (String? value) {
          setState(() {
            addEditInt = value!;
          });
        },
      ),
    );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {}, // make an optional param in 'AddWard'
                      ),
                      CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xffdadada),
                          backgroundImage: NetworkImage(wardModel.imageUrl)),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${wardModel.shortName}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            // overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${wardModel.description}",
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text('Pt\'s Details:  '),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 5,
                            controller: yourScrollController,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: ListView(
                                controller: yourScrollController,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  createRLT('0'),
                                  createRLT('1'),
                                  createRLT('2'),
                                  createRLT('3'),
                                  createRLT('4'),
                                  createRLT('5'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: tec,
                    decoration: InputDecoration(
                      hintText: 'Beds eg. 1-3,5,10',
                      labelText: 'Job List',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.print),
                        onPressed: () {},
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'(^[0-9]+(?:(?:\s*,\s*|-)[0-9]+)*$)'))
                    ],
                  ),
                ],
              ),
              Divider(color: Colors.black, thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 14),
                  Text(
                    'Beds',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    textAlign: TextAlign.left, //dunno got use or not
                  ),
                  SizedBox(width: 14),
                  Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                          border: Border.all()),
                      child: IconButton(
                        onPressed: () {
                          Get.to(AsBedScreen(wardModel));
                        },
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                          border: Border.all()),
                      child: IconButton(
                        onPressed: () {},
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.black,
                        ),
                      )),
                ],
              ),
              FutureBuilder<List<BedModel>>(
                  future: gbfws, // getBedsForWS(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<BedModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // setState(() {
                      masterBedIdList =
                          snapshot.data!.map((bm) => bm.id).toList();
                      // });
                      return Expanded(
                          flex: 1,
                          child: ListView(
                            children: [
                              ExpansionPanelList.radio(
                                dividerColor: Colors.blue,
                                expansionCallback: (i, ii) {
                                  if (ii)
                                    setState(() {
                                      masterBedId = masterBedIdList[i];
                                    });
                                },
                                children: snapshot.data!
                                    .asMap()
                                    .entries
                                    .map((bme) => ExpansionPanelRadio(
                                        value: bme.value.id,
                                        headerBuilder: (context, isExpanded) {
                                          // if (bme.value.ptInitialised)
                                          //   print(bme.value.wardPtModel.id);
                                          return ListTile(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                              Radius.circular(4),
                                            )),
                                            leading: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(4),
                                                    ),
                                                    border: Border.all()),
                                                child: IconButton(
                                                  onPressed: () {},
                                                  visualDensity:
                                                      const VisualDensity(
                                                          horizontal: -4,
                                                          vertical: -4),
                                                  icon: Icon(
                                                    Icons.bed,
                                                    color: Colors.black,
                                                  ),
                                                )),
                                            onTap: () {
                                              if (bme.value.ptInitialised) {
                                                currentWPLC.cbm.value =
                                                    bme.value;
                                                currentWPLC.cwpm.value =
                                                    bme.value.wardPtModel;
                                                currentWPLC
                                                    .updatePtDetailsConts(
                                                        bme.value.wardPtModel);
                                              }
                                              bme.value.ptInitialised
                                                  ? Get.to(PtScreen())
                                                  : !bme.value.error
                                                      ? Get.to(BedScreen(
                                                          bme.value, wardModel))
                                                      : Get.snackbar(
                                                          "Error retrieving patient data",
                                                          'Please refresh ward page.',
                                                          snackPosition:
                                                              SnackPosition
                                                                  .BOTTOM,
                                                          backgroundColor:
                                                              Colors.red);
                                            },
                                            title: Text(
                                                '${bme.key + 1}. ${bme.value.name}\nPt: ${bme.value.ptInitialised ? bme.value.wardPtModel.ptDetails() : "-"}',
                                                style: TextStyle(
                                                    fontWeight: isExpanded
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isExpanded
                                                        ? Colors.black
                                                        : Colors.black87)),
                                            tileColor: isExpanded
                                                ? Colors.blue
                                                : Colors.white,
                                          );
                                        },
                                        body: bme.value.ptInitialised
                                            ? case2(
                                                addEditInt,
                                                // bme.value.wardPtModel.id
                                                masterBedId)
                                            : Container()))
                                    .toList(),
                              )
                            ],
                          )

                          // BedExpansionTile(
                          //   bedModel.name,
                          //   'Pt: ' +
                          //       (bedModel.ptInitialised
                          //           ? bedModel.wardPtModel.ptDetails()
                          //           : '-'),
                          //   false,
                          //   () {
                          //     print('hey');
                          //     if (bedModel.ptInitialised) {
                          //       currentWPLC.cbm.value = bedModel;
                          //       currentWPLC.cwpm.value = bedModel.wardPtModel;
                          //       currentWPLC.updatePtDetailsConts(bedModel.wardPtModel);
                          //     }

                          //     bedModel.ptInitialised
                          //         ? Get.to(PtScreen())
                          //         : !bedModel.error
                          //             ? Get.to(BedScreen(bedModel, wardModel))
                          //             : Get.snackbar(
                          //                 "Error retrieving patient data",
                          //                 'Please refresh ward page.',
                          //                 snackPosition: SnackPosition.BOTTOM,
                          //                 backgroundColor: Colors.red,
                          //               );
                          //   },
                          // )

                          // ListView(
                          //   shrinkWrap: true,
                          //   children: snapshot.data!,
                          // )

                          );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}

// class BedExpansionTile extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final bool checked;
//   final void Function() checkFn;
//   // final vslist = ['HR', 'SYS', 'DIA', 'RR', 'O2', 'Temp', 'Notes'].asMap().forEach((i, v) => vsList.add(
//   //       VsTextField(v, sendDataMap, saveData, i == (vitalsTitle.length - 1))));

//   BedExpansionTile(this.title, this.subtitle, this.checked, this.checkFn);

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text(title, overflow: TextOverflow.ellipsis),
//       subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
//       leading: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // GestureDetector(
//           //   child: checked
//           //       ? Icon(Icons.check_box, size: 20)
//           //       : Icon(Icons.check_box_outline_blank, size: 20),
//           //   onTap: () => print(ecController.asdljk),
//           // ),
//           // SizedBox(width: 10),
//           GestureDetector(
//             child: Icon(Icons.file_open, size: 20),
//             onTap: checkFn,
//           ),
//         ],
//       ),
//       children: [
//         SizedBox(height: 10),
//         ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: 120,
//           ),
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(6),
//             reverse: false,
//             child: TextFormField(
//               key: ValueKey('diagnosis'),
//               // controller: currentWPLC.cpCurDiag,
//               // onChanged: (yes) => ecController.checkOnChange(),
//               initialValue: 'sjhagdjahsg',
//               decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1.0),
//                   ),
//                   labelText: 'Diagnosis',
//                   contentPadding: const EdgeInsets.all(4.0),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.save),
//                     onPressed: () {},
//                   )),
//               keyboardType: TextInputType.multiline,
//               maxLines: null,
//             ),
//           ),
//         ),
//         SizedBox(height: 20),
//         ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: 120,
//           ),
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(6),
//             reverse: false,
//             child: TextFormField(
//               key: ValueKey('plan'),
//               // controller: currentWPLC.cpCurPlan,
//               // onChanged: (yes) => ecController.checkOnChange(),
//               initialValue:
//                   'lkj \nasd \nlkj \nasdlkj \nasdlkj \nasdlkj \nasdlkj \nasdlkj \nasd \nasdlkj \nasd',
//               decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1.0),
//                   ),
//                   labelText: 'Plan',
//                   contentPadding: const EdgeInsets.all(4.0),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.save),
//                     onPressed: () {},
//                   )),
//               keyboardType: TextInputType.multiline,
//               maxLines: null,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         ConstrainedBox(
//           constraints: new BoxConstraints(
//             maxHeight: 130,
//           ),
//           child: SingleChildScrollView(
//             reverse: true,
//             child: TextFormField(
//               // focusNode: focusNode,
//               // controller: controller,
//               // onEditingComplete: onEditingComplete,
//               key: ValueKey('entry'),
//               onChanged: (yes) {
//                 ecController.checkOnChange();
//               },
//               validator: (val) {
//                 if (val!.trim().isEmpty) {
//                   return 'Review/Entry cannot be empty!';
//                 }
//                 return null;
//               },
//               decoration: InputDecoration(
//                   labelText: 'Review / Entry',
//                   contentPadding: const EdgeInsets.all(4.0),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.save),
//                     onPressed: () {},
//                   )),
//               keyboardType: TextInputType.multiline,
//               maxLines: null,
//             ),
//           ),
//         ),
//         Container(
//           height: 55,
//           width: MediaQuery.of(context).size.width,
//           child: Padding(
//             padding: const EdgeInsets.all(3.0),
//             child: Scrollbar(
//               scrollbarOrientation: ScrollbarOrientation.bottom,
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     Container(
//                       padding:
//                           EdgeInsets.only(top: 7, left: 5, right: 5, bottom: 4),
//                       width: 120,
//                       child: TextFormField(
//                         key: ValueKey('date'),
//                         // controller: dobCont,
//                         // validator:
//                         //     RequiredValidator(errorText: 'Date is required'),
//                         readOnly: true,
//                         decoration: InputDecoration(
//                           labelText: 'Date',
//                           suffixIcon: IconButton(
//                               icon: Icon(Icons.calendar_today),
//                               onPressed: () {} //_selectDate(context),
//                               ),
//                           border: OutlineInputBorder(
//                             borderSide:
//                                 BorderSide(color: Colors.black, width: 1.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                         padding: EdgeInsets.only(
//                             top: 7, left: 5, right: 5, bottom: 4),
//                         width: 120,
//                         child: TextFormField(
//                           key: ValueKey('time'),
//                           // controller: timeCont,
//                           // validator:
//                           //     RequiredValidator(errorText: 'Time is required'),
//                           readOnly: true,
//                           decoration: InputDecoration(
//                             labelText: 'Time',
//                             suffixIcon: IconButton(
//                                 icon: Icon(Icons.access_time),
//                                 onPressed: () {} // => _selectTime(context),
//                                 ),
//                             border: OutlineInputBorder(
//                               borderSide:
//                                   BorderSide(color: Colors.black, width: 1.0),
//                             ),
//                           ),
//                         )),
//                     // ...vsList
//                   ],
//                 ),
//                 // ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class BloodResTextField extends StatelessWidget {
  final String paramName;
  BloodResTextField(this.paramName);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 7, left: 5, right: 5, bottom: 4),
      width: 150,
      child: TextFormField(
        initialValue: ecController.bloodResMap[paramName]!,
        maxLines: 1,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          labelText: paramName,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'(^\-?(\d+)?\.?\d{0,4})'))
        ],
        onChanged: (val) => ecController.bloodResMap[paramName] = val,
      ),
    );
  }
}
