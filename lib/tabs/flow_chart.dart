import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:horizontal_data_table/refresh/pull_to_refresh/pull_to_refresh.dart';
import 'package:mahospital/cameras/flow_chart_camera.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
// import 'package:memodx/widgets/extract_text_camera.dart';

class FlowChart extends StatefulWidget {
  @override
  _FlowChartState createState() => _FlowChartState();
}

class _FlowChartState extends State<FlowChart> {
  // String imagePath;
  late CameraDescription camera;
  // List<CameraDescription> cameras;
  DateTime selectedDate = DateTime.now();

  // List<String> dates = [
  // '01/05',
  // '02/05',
  // '03/05',
  // '04/05',
  // '05/05',
  // '06/05',
  // '07/05',
  // '08/05',
  // '09/05',
  // '10/05',
  // '11/05',
  // '00/00',
  // ];

  List<String> bloodParam = [
    'Hb',
    'Twc',
    'Hct',
    'Plt',
    'Na',
    'K',
    'Cl',
    'Urea',
    'Creat',
  ];

  // late double hb;
  // late double twc;
  // late double hct;
  // late double plt;
  // late double na;
  // late double k;
  // late double cl;
  // late double urea;
  // late double creat;
  late List<List<String>>
      wer; // it seems that im saving it as string, then it can be saved as an empty string
  late int numberOfDays;
  Map<String, List<String>> masterMap = {};
  Map<String, dynamic> initialMap = {};
  // i think just make it into a Map

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    availableCameras().then((availableCameras) {
      // cameras = availableCameras;
      camera = availableCameras.first;
    });
    // wer = [hb, twc, hct, plt, na, k, cl, urea, creat];

    super.initState();
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        dobCont.text = DateFormat('dd/MM/yyyy').format(picked);
      });
  }

  TimeOfDay selectedTime = TimeOfDay.now();

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

  Widget _getTitleItemWidget(int dateTimeFromMilli) {
    var timi = DateTime.fromMillisecondsSinceEpoch(dateTimeFromMilli);
    return Container(
      height: 90,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        ),
      ),
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Column(
            children: [
              Text(DateFormat('dd/MM/yyyy').format(timi)),
              Text(DateFormat('kk:mm').format(timi)),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
      ),
    );
    // Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: <Widget>[
    // IconButton(
    //   icon: Icon(Icons.calendar_today),
    //   onPressed: () => _selectDate(context),
    // ),

    // date == ''
    //     ? IconButton(
    //         // need to change to dialog
    //         icon: Icon(Icons.add_box),
    //         onPressed: () async {
    //           imagePath = await Navigator.of(context).push(
    //             MaterialPageRoute(
    //               builder: (c) {
    //                 return ExtractTextCamera(camera); // need to change
    //               },
    //             ),
    //           );
    //           interpret(imagePath);
    //         },
    //       )
    //     : Container(),
    // Container(
    //   child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
    //   width: width,
    //   height: 56,
    //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
    //   alignment: Alignment.centerLeft,
    // ),
    // ],
  }

  final dobCont = TextEditingController();
  final timeCont = TextEditingController();
  bool loading = false;
  late DocumentReference fc;
  Map<String, dynamic> res = {};

  List<Widget> _getTitleWidget() {
    List<Widget> sth = [];
    sth.add(Container(
      height: 90,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        ),
      ),
      // padding: EdgeInsets.all(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_right),
            // ElevatedButton(
            //   child: Text(
            //     String.fromCharCode(0x2192),
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            onPressed: () async {
              await Get.defaultDialog(
                title: 'Add Results',
                contentPadding: EdgeInsets.all(15.0),
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.65),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              key: ValueKey('date'),
                              controller: dobCont,
                              // controller: _dobController,
                              keyboardType: TextInputType.datetime,
                              validator: RequiredValidator(
                                  errorText: 'Date is required'),
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
                              keyboardType: TextInputType.datetime,
                              validator: RequiredValidator(
                                  errorText: 'Time is required'),
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
                                      // Map<String, dynamic> results =
                                      print('its pressed');
                                      Get.to(FlowChartCamera(camera),
                                          preventDuplicates: false);
                                      // print(results);
                                      // print(
                                      //     'print something mtfk this is my dream');
                                      // setState(() => res.addAll(results));
                                    },
                                  )
                                : Container(),
                            Obx(() => Container(
                                child:
                                    Text(ecController.ixResults.toString()))),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Hb',
                              ),
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
                                          initialMap
                                              .addAll(ecController.ixResults);
                                          ecController.ixResults =
                                              RxMap<String, dynamic>();
                                        }
                                        if (fcss.exists) {
                                          Map<String, dynamic> bloods =
                                              fcss.get('bloods');
                                          bloods[dateInUTC.toString()] =
                                              initialMap;

                                          fc.update({'bloods': bloods}).then(
                                              (v) {
                                            Get.back();
                                          });
                                        } else {
                                          fc.set({
                                            'bloods': {dateInUTC: initialMap}
                                          }).then((v) {
                                            Get.back();
                                          });
                                        }
                                      }
                                    })
                                : CircularProgressIndicator()
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
              setState(() {
                loading = false;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_drop_down),
            // TextButton(
            //   style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
            //   child: Text(
            //     String.fromCharCode(0x2193),
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            onPressed: () {},
          ),
        ],
      ),
    ));
    print(numberOfDays);
    if (numberOfDays != 0)
      orderedDateTime.forEach((dt) {
        sth.add(_getTitleItemWidget(int.parse(dt)));
      });
    return sth;
  }

  Future<void> interpret(String path) async {
    // if (path != null) {
    //   var inputImage = InputImage.fromFilePath(path);
    //   regText = await _textDetector.processImage(inputImage);
    //   List<String> creds = LineSplitter.split(regText.text).toList();
    //   createCards(creds);
    // }
  }

  Widget _generateFirstColumn(BuildContext context, int index) {
    return Container(
      child: Text(bloodParam[index]),
      width: 60,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
    );
  }

  Widget _generateRightHandSideRow(BuildContext context, int index) {
    List ascNum = List.generate(numberOfDays, (i) => i);
    List<Widget> rowChildren = [];
    for (var ii in ascNum) {
      rowChildren.add(Container(
        child: Text(wer[index][ii]),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
          ),
        ),
        // padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.center,
      ));
    }
    return Row(
      children: rowChildren,
    );
  }

  Future<List> getFlowChartData(String id) async {
    bloodParam.forEach((bp) => masterMap[bp] = []);
    bloodParam.forEach((bp) => initialMap[bp] = '');
    fc = wardPtRef.doc(id).collection('flowCharts').doc('1');
    DocumentSnapshot fcSS = await fc.get();
    if (fcSS.exists) {
      Map bloodMap = fcSS.get('bloods');
      orderedDateTime = bloodMap.keys.toList();
      numberOfDays = orderedDateTime.length;
      orderedDateTime.sort((a, b) => int.parse(b)
          .compareTo(int.parse(a))); // reversed - actually no need int.parse
      for (var odt in orderedDateTime) {
        print(odt);
        Map bloodValues = bloodMap[odt];
        // var keys = bloodValues.keys.toList();
        bloodParam.forEach((bp) {
          // if (keys.contains(bp))
          masterMap[bp]!.add(bloodValues[bp]);
          // else
          //   masterMap[bp]!.add('');
        });
      }
      List<List<String>> masterList = [];
      for (var bpp in bloodParam) {
        masterList.add(masterMap[bpp]!);
      }
      wer = masterList;
      return masterList;
    } else {
      List<List<String>> emptyList = [];
      bloodParam.forEach((bp) => emptyList.add(['']));
      wer = emptyList;
      numberOfDays = 0;
      // sth.add(Container(
      //   width: 60,
      //   height: 80,
      // ));
      // wer = [];
      return [];
    }
  }

  HDTRefreshController _hdtRefreshController = HDTRefreshController();
  late List orderedDateTime;

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureBuilder<List>(
          future: getFlowChartData(currentWPLC.cwpm.value.id),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  height: constraints.maxHeight,
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 60,
                    rightHandSideColumnWidth: numberOfDays * 60,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidget(),
                    leftSideItemBuilder: _generateFirstColumn,
                    rightSideItemBuilder: _generateRightHandSideRow,
                    itemCount: bloodParam.length,
                    rowSeparatorWidget: const Divider(
                      color: Colors.black54,
                      height: 1.0,
                      thickness: 0.0,
                    ),
                    leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
                    rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
                    enablePullToRefresh: true,
                    refreshIndicator: const WaterDropHeader(),
                    refreshIndicatorHeight: 30,
                    onRefresh: () {
                      setState(() {});
                      _hdtRefreshController.refreshCompleted();
                    },
                    htdRefreshController: _hdtRefreshController,
                  ),
                );
              });
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

// String.fromCharCode(0x2B) +
