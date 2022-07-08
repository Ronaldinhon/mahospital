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
          // height: 333,
          // constraints: BoxConstraints(
          //     maxHeight: MediaQuery.of(context).size.height * 0.65),
          child:
              //try first lah
              SingleChildScrollView(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ecController.editFcEntry.value
                    ? 'Edit Results'
                    : 'Add Results'),
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
                // the way to go is make a separate stateless widget with a testeditingcontroller inside
                // we need 40 of those - with params name string
                SizedBox(
                  width: 200,
                  height: 300,
                  child: Scrollbar(
                      child: ListView(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Hb',
                        ),
                        maxLength: 30,
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Hb'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Twc',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Twc'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Hct',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Hct'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Plt',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Plt'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Na',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Na'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'K',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['K'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cl',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Cl'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Urea',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Urea'] = val);
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Creat',
                        ),
                        onSaved: (val) {
                          if (val != null)
                            setState(() => initialMap['Creat'] = val);
                        },
                      ),
                    ],
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
                            setState(() => loading = true);
                            _formKey.currentState!.save();
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
                    : CircularProgressIndicator()
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
