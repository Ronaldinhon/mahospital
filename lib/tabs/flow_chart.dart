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
  // List<CameraDescription> cameras;

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
    'TProt',
    'Alb',
    'Glob',
    'TBil',
    'ALT',
    'AST',
    'ALP',
    'Ca',
    'Phos',
    'Mg',
    'CK',
    'LDH',
  ]; // uncomment all will result in record without attribute to cause error !!!

  // late List<List<String>>
  //     wer; // it seems that im saving it as string, then it can be saved as an empty string
  // late int numberOfDays;
  // late List ascNum;
  // late List orderedDateTime;

  // late Future<List> bloodIx;

// numberOfDays
// ascNum
// orderedDateTime
// wer

  // Map<String, List<String>> masterMap = {};

  @override
  void initState() {
    // bloodIx = getFlowChartData(currentWPLC.cwpm.value.id);
    // wer = [hb, twc, hct, plt, na, k, cl, urea, creat];

    super.initState();
  }

  Widget _getTitleItemWidget(int dateTimeFromMilli) {
    var timi = DateTime.fromMillisecondsSinceEpoch(dateTimeFromMilli);
    return Material(
        child: InkWell(
            splashColor: Colors.red,
            onTap: () => print('yeah'),
            child: Container(
              height: 110,
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
                      Icon(Icons.edit, size: 18),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ),
              ),
            )));
  }

  List<Widget> _getTitleWidget() {
    List<Widget> sth = [];
    sth.add(Container(
      padding: EdgeInsets.all(5),
      height: 110,
      width: 60,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        ),
      ),
      // padding: EdgeInsets.all(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              child: Icon(
                Icons.arrow_right,
                color: Colors.black,
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
              // ElevatedButton(
              //   child: Text(
              //     String.fromCharCode(0x2192),
              //     style: TextStyle(fontWeight: FontWeight.bold),
              //   ),
              onPressed: () => ecController.entryFC.value = true
              // async {
              //   await Get.defaultDialog(
              //     title: 'Add Results',
              //     contentPadding: EdgeInsets.all(15.0),
              //     content: StatefulBuilder(
              //         builder: (BuildContext context, StateSetter setState) {
              //       return
              //     }),
              //   );
              //   setState(() {
              //     loading = false;
              //   });
              // },
              ),
          ElevatedButton(
            child: Icon(
              Icons.print,
              color: Colors.black,
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            onPressed: () => ecController.printingFC.value = true,
          ),
          ElevatedButton(
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
            onPressed: () => ecController.editFCparam.value = true,
          )
          // IconButton(
          //   icon: Icon(Icons.arrow_drop_down),
          //   // TextButton(
          //   //   style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
          //   //   child: Text(
          //   //     String.fromCharCode(0x2193),
          //   //     style: TextStyle(fontWeight: FontWeight.bold),
          //   //   ),
          //   onPressed: () {},
          // ),
        ],
      ),
    ));
    // print(numberOfDays);
    if (ecController.numberOfDays != 0)
      ecController.orderedDateTime.forEach((dt) {
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
    return Material(
      child: InkWell(
        splashColor: Colors.red,
        onTap: () => addFCvalue(bloodParam[index], index),
        child: Container(
          child: Text(bloodParam[index]),
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  void addFCvalue(String head, int index) {
    List<String> ixVals = [];
    for (var ii in ecController.ascNum) {
      if (ecController.wer[index][ii].isNotEmpty)
        ixVals.add(ecController.wer[index][ii]);
    }
    String oyster = '\n$head ' + ixVals.join(" <--");
    ecController.mainEditor.text += oyster;
  }

  Widget _generateRightHandSideRow(BuildContext context, int index) {
    List<Widget> rowChildren = [];
    for (var ii in ecController.ascNum) {
      rowChildren.add(Container(
        child: Text(ecController.wer[index][ii]),
        width: 60,
        height: 40,
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

  late DocumentReference fc;
  Future<List> getFlowChartData(String id) async {
    bloodParam.forEach((bp) => ecController.masterMap[bp] = []);
    fc = wardPtRef.doc(id).collection('flowCharts').doc('1');
    DocumentSnapshot fcSS = await fc.get();
    if (fcSS.exists) {
      Map bloodMap = fcSS.get('bloods');
      ecController.orderedDateTime = bloodMap.keys.toList();
      ecController.numberOfDays = ecController.orderedDateTime.length;
      ecController.ascNum = List.generate(ecController.numberOfDays, (i) => i);
      ecController.orderedDateTime.sort((a, b) => int.parse(b)
          .compareTo(int.parse(a))); // reversed - actually no need int.parse
      for (var odt in ecController.orderedDateTime) {
        // print(odt);
        Map bloodValues = bloodMap[odt];
        // var keys = bloodValues.keys.toList();
        bloodParam.forEach((bp) {
          // if (keys.contains(bp))
          ecController.masterMap[bp]!.add(bloodValues[bp]);
          // else
          //   masterMap[bp]!.add('');
        });
      }
      List<List<String>> masterList = [];
      for (var bpp in bloodParam) {
        masterList.add(ecController.masterMap[bpp]!);
      }
      // print(masterList);
      ecController.wer = masterList;
      return masterList;
    } else {
      List<List<String>> emptyList = [];
      bloodParam.forEach((bp) => emptyList.add(['']));
      ecController.wer = emptyList;
      ecController.numberOfDays = 0;
      // sth.add(Container(
      //   width: 60,
      //   height: 80,
      // ));
      // wer = [];
      return [];
    }
  }

  HDTRefreshController _hdtRefreshController = HDTRefreshController();

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureBuilder<List>(
          future: getFlowChartData(currentWPLC.cwpm.value
              .id), // use this ba, table will change on pt change, if want to limit data call, limit in function ba
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  height: constraints.maxHeight,
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 60,
                    rightHandSideColumnWidth: ecController.numberOfDays * 60,
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
                      // getFlowChartData(currentWPLC.cwpm.value.id); <-- this line automatically called on refresh
                      setState(() {});
                      _hdtRefreshController.refreshCompleted();
                    },
                    htdRefreshController: _hdtRefreshController,
                  ),
                );
              });
            } else {
              return Center(
                  child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator()));
            }
          },
        ));
  }
}

// String.fromCharCode(0x2B) +
