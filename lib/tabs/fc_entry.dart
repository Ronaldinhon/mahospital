import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:intl/intl.dart';

import '../cameras/flow_chart_camera.dart';
import '../helpers/reponsiveness.dart';

class FcEntry extends StatefulWidget {
  @override
  _FcEntryState createState() => _FcEntryState();
}

class _FcEntryState extends State<FcEntry> {
  late String uid;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late CameraDescription camera;
  late DocumentReference fc;

  List<String> bloodParam = [
    'Hb',
    'Hct',
    'Plt',
    'Twc',
    'Na',
    'K',
    'Cl',
    'Urea',
    'Creat',
    // 'Hb',
    // 'Hct',
    // 'MCV',
    // 'MCH',
    // 'Plt',
    // 'Twc',
    // 'PMN',
    // 'Lymph',
    // 'Eos',
    // 'Mono',
    // 'Urea',
    // 'Creat',
    // 'Na',
    // 'K',
    // 'Cl',
    // 'Ca',
    // 'Phos',
    // 'Mg',
    // 'TBil',
    // 'Dir',
    // 'Indir',
    // 'Pro',
    // 'Alb',
    // 'Glob',
    // 'ALT',
    // 'ALP',
    // 'CK',
    // 'AST',
    // 'LDH',
    // 'PT',
    // 'APTT',
    // 'INR',
    // 'ESR',
    // 'CRP',
    // 'T4',
    // 'TSH',
    // 'ferri',
    // 'iron',
    // 'UIBC',
    // 'TIBC',
    // 'Tr.Sat',
  ];

  // how to deal with data change in appwrite??
  // mark original 'lastest' as false after edit. Yeahhh

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    dobCont.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    timeCont.text =
        selectedTime.hour.toString() + ':' + selectedTime.minute.toString();
    availableCameras().then((availableCameras) {
      camera = availableCameras.first;
    });
    bloodParam.forEach((bp) => initialMap[bp] = '');
    fc = wardPtRef
        .doc(currentWPLC.cwpm.value.id)
        .collection('flowCharts')
        .doc('1');
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final dobCont = TextEditingController();
  final timeCont = TextEditingController();
  Map<String, dynamic> initialMap = {};
  // i think just make it into a Map
  bool loading = false;
  final bloodList = [
    'Hb',
    'Twc',
    'Hct',
    'Plt',
    'Na',
    'K',
    'Cl',
    'Urea',
    'Creat'
  ];

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
        dobCont.text = DateFormat('dd/MM/yyyy').format(picked);
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
        timeCont.text =
            pickedS.hour.toString() + ':' + pickedS.minute.toString();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Form(
        key: _formKey,
        child: Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      child: Text('<- Back'),
                      onPressed: () => ecController.entryFC.value = false,
                    ),
                  ],
                ),
                Text(
                  ecController.editFcEntry.value
                      ? 'Edit Results'
                      : 'Add Results',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  key: ValueKey('date'),
                  controller: dobCont,
                  // keyboardType: TextInputType.datetime,
                  readOnly: true,
                  validator: RequiredValidator(errorText: 'Date is required'),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
                TextFormField(
                  key: ValueKey('time'),
                  controller: timeCont,
                  readOnly: true,
                  // keyboardType: TextInputType.datetime,
                  validator: RequiredValidator(errorText: 'Time is required'),
                  decoration: InputDecoration(
                    labelText: 'Time',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                ),
                !kIsWeb
                    ? IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          Get.to(FlowChartCamera(camera),
                              preventDuplicates: false);
                        },
                      )
                    : Container(),
                Obx(() => Container(
                    child: Text(ecController.ixResults.isEmpty
                        ? ''
                        : ecController.ixResults.toString()))),
                SizedBox(
                  height: 8,
                ),
                /* the way to go is make a separate stateless widget with a texteditingcontroller inside
                we need 40 of those - with params name string
                i think 40 texteditingcontroller is too much... 
                separate stateless widget, call on save here can???? 
                - we'll try should be fine. yeahhh - with master map in GetController, 
                 upon change pt need to empty it */
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Fill in / Overrride camera results',
                        style: TextStyle(fontSize: 8))
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 300,
                  child: Scrollbar(
                      child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //   crossAxisCount:
                          //       ResponsiveWidget.isSmallScreen(context) ? 2 : 3,
                          // ),
                          children: bloodParam
                              .map((paramName) =>
                                  BpTextField(paramName, initialMap))
                              .toList()
                          //   TextFormField(
                          //     scrollPadding: EdgeInsets.all(5),
                          //     keyboardType: TextInputType.number,
                          //     textInputAction: TextInputAction.next,
                          //     decoration: InputDecoration(
                          //       labelText: 'Hb',
                          //     ),

                          )),
                ),
                SizedBox(
                  height: 8,
                ),
                !loading
                    ? ElevatedButton(
                        child: Text('Save'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // setState(() => loading = true);
                            _formKey.currentState!.save();
                            print(initialMap);
                            // do i need to setstate onSave ???
                            DocumentSnapshot fcss = await fc.get();
                            String dateInUTC = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime.hour,
                                    selectedTime.minute)
                                .millisecondsSinceEpoch
                                .toString();
                            if (ecController.ixResults.isNotEmpty) {
                              initialMap.addAll(ecController.ixResults);
                              ecController.ixResults = RxMap<String, dynamic>();
                            }
                            if (fcss.exists) {
                              Map<String, dynamic> bloods = fcss.get('bloods');
                              bloods[dateInUTC.toString()] = initialMap;

                              fc.update({'bloods': bloods}).then((v) {
                                ecController.entryFC.value = false;
                              });
                            } else {
                              fc.set({
                                'bloods': {dateInUTC: initialMap}
                              }).then((v) {
                                ecController.entryFC.value = false;
                              });
                            }
                          }
                        })
                    : CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class BpTextField extends StatelessWidget {
  final String paramName;
  final Map iniMap;

  BpTextField(this.paramName, this.iniMap);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      scrollPadding: EdgeInsets.all(5),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: paramName,
      ),
      onSaved: (val) {
        if (val != null) iniMap[paramName] = val;
      },
    );
  }
}
