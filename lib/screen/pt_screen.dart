import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/controllers/list_current_ward_pts_controller.dart';
import 'package:mahospital/helpers/reponsiveness.dart';
import 'package:mahospital/tabs/flow_chart.dart';
import 'package:mahospital/tabs/imaging_tab.dart';
import 'package:mahospital/tabs/pt_details.dart';
import 'package:mahospital/tabs/records.dart';
import 'package:mahospital/tabs/rer_pdf.dart';
import 'package:mahospital/tabs/summary.dart';
// import 'package:memodx/foundation/pdf_path.dart';
// import 'package:memodx/tabs/download_tab.dart';
// import 'package:memodx/tabs/drug_charts.dart';
// import 'package:memodx/tabs/flow_chart.dart';
// import 'package:memodx/tabs/imaging_tab.dart';
// import 'package:memodx/tabs/preview_pdf.dart';
// import 'package:memodx/tabs/pt_details.dart';
// import 'package:memodx/tabs/rer_pdf_download.dart';
// import 'package:memodx/tabs/rer_tab.dart';
// import 'package:memodx/tabs/summary_pdf.dart';
// import 'package:memodx/tabs/temp_chart.dart';
// import 'package:memodx/tabs/vitals_chart.dart';
import 'package:provider/provider.dart';

class PtScreen extends StatefulWidget {
  @override
  _PtScreenState createState() => _PtScreenState();
}

class _PtScreenState extends State<PtScreen> {
  late File pdf;
  // TabController _tabController;

  void _incrementCounter() {
    currentWPLC.increment();
  }

  void _decrementCounter() {
    currentWPLC.decrement();
  }

  Widget tabBar(String tabTitle) {
    return SizedBox(
        height: 33,
        child: Tab(
          child: Text(tabTitle),
        ));
  }

  void upLevelPdf(File file, BuildContext context) {
    // setState(() {
    // Provider.of<PdfPath>(context, listen: false).setPath(file.path);
    pdf = file;
    // _tabController.animateTo(12);
    // });
  }

  @override
  void initState() {
    super.initState();
    // _tabController = new TabController(vsync: this, length: 14);
  }

  double _ratio = 0.5;
  final _dividerWidth = 16.0;
  double _maxWidth = 0;

  get _width1 => _ratio * _maxWidth;

  get _width2 => (1 - _ratio) * _maxWidth;

  @override
  Widget build(BuildContext context) {
    return (ResponsiveWidget.isMediumScreen(context) ||
            ResponsiveWidget.isLargeScreen(context))
        ? LayoutBuilder(builder: (context, BoxConstraints constraints) {
            assert(_ratio <= 1);
            assert(_ratio >= 0);
            if (_maxWidth == 0)
              _maxWidth = constraints.maxWidth - _dividerWidth;
            if (_maxWidth != constraints.maxWidth) {
              _maxWidth = constraints.maxWidth - _dividerWidth;
            }

            return Obx(() => Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        ElevatedButton(
                          child: Icon(Icons.arrow_left),
                          onPressed: () => _decrementCounter(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currentWPLC.cbm.value.name),
                            Text(currentWPLC.cwpm.value.name),
                          ],
                        ),
                        ElevatedButton(
                          child: Icon(Icons.arrow_right),
                          onPressed: () => _incrementCounter(),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                    ),
                  ),
                  body: SizedBox(
                    width: constraints.maxWidth,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: _width1,
                          child: Container(
                            child: DefaultTabController(
                              length: 5,
                              child: Column(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                    height: 50,
                                    width: _width1,
                                    child: TabBar(
                                        isScrollable: true,
                                        unselectedLabelColor:
                                            Colors.white.withOpacity(0.3),
                                        indicatorColor: Colors.white,
                                        tabs: [
                                          tabBar('Pt Details'),
                                          tabBar('RER'),
                                          tabBar('Summary'),
                                          tabBar('FlowChart'),
                                          tabBar('Imaging'),
                                        ]),
                                  ),
                                  Expanded(
                                    child: TabBarView(children: <Widget>[
                                      PtDetails(),
                                      Records(),
                                      RerPdf(),
                                      FlowChart(),
                                      ImagingTab(),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: SizedBox(
                            width: _dividerWidth,
                            height: constraints.maxHeight,
                            child: RotationTransition(
                              child: Icon(Icons.drag_handle),
                              turns: AlwaysStoppedAnimation(0.25),
                            ),
                          ),
                          onPanUpdate: (DragUpdateDetails details) {
                            setState(() {
                              _ratio += details.delta.dx / _maxWidth;
                              if (_ratio > 1)
                                _ratio = 1;
                              else if (_ratio < 0.0) _ratio = 0.0;
                            });
                          },
                        ),
                        SizedBox(
                          width: _width2,
                          child: Container(
                            child: DefaultTabController(
                              length: 5,
                              child: Column(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                    height: 50,
                                    width: _width2,
                                    child: TabBar(
                                        isScrollable: true,
                                        unselectedLabelColor:
                                            Colors.white.withOpacity(0.3),
                                        indicatorColor: Colors.white,
                                        tabs: [
                                          tabBar('Pt Details'),
                                          tabBar('RER'),
                                          tabBar('Summary'),
                                          tabBar('FlowChart'),
                                          tabBar('Imaging'),
                                        ]),
                                  ),
                                  Expanded(
                                    child: TabBarView(children: <Widget>[
                                      PtDetails(),
                                      Records(),
                                      RerPdf(),
                                      FlowChart(),
                                      ImagingTab(),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          })
        : Obx(() => DefaultTabController(
              length: 5,
              child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      ElevatedButton(
                        child: Icon(Icons.arrow_left),
                        onPressed: () => _decrementCounter(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(currentWPLC.cbm.value.name),
                          Text(currentWPLC.cwpm.value.name),
                        ],
                      ),
                      ElevatedButton(
                        child: Icon(Icons.arrow_right),
                        onPressed: () => _incrementCounter(),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                  ),
                  bottom: TabBar(
                      isScrollable: true,
                      unselectedLabelColor: Colors.white.withOpacity(0.3),
                      indicatorColor: Colors.white,
                      tabs: [
                        tabBar('Pt Details'),
                        tabBar('RER'),
                        tabBar('Preview'),
                        tabBar('FlowChart'),
                        tabBar('Imaging'),
                        // tabBar('RER'),
                        // tabBar('Vitals'),
                        // tabBar('Temp'),
                        // tabBar('F/C'),
                        // tabBar('ECG'),
                        // tabBar('CC'),
                        // tabBar('Images'),
                        // tabBar('Drugs'),
                        // tabBar('I/O'),
                        // tabBar('Generate'),
                        // tabBar('Preview'),
                        // tabBar('Download'),
                      ]),
                ),
                body: TabBarView(children: <Widget>[
                  PtDetails(),
                  Records(),
                  RerPdf(),
                  FlowChart(),
                  ImagingTab(),
                  // RerPdfDownload(upLevelPdf),
                  // RerTab(),
                  // VitalsChart(),
                  // TempChart(),
                  // Center(child: Text('ECG...')),
                  // Center(child: Text('Culture, Cytology, HPE...')),
                  // DrugCharts(),
                  // Center(child: Icon(Icons.monetization_on)),
                  // Center(child: Text('Generate')),
                  // DownloadTab(filePath: pdf == null ? null : pdf.path),
                ]),
              ),
            ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Obx(() => DefaultTabController(
  //         length: 2,
  //         child: Scaffold(
  //           appBar: AppBar(
  //             title: Row(
  //               children: [
  //                 ElevatedButton(
  //                   child: Icon(Icons.arrow_left),
  //                   onPressed: () => _decrementCounter(),
  //                 ),
  //                 Text(currentWPLC.cbm.value.name +
  //                     ' - ' +
  //                     currentWPLC.cwpm.value.name),
  //                 ElevatedButton(
  //                   child: Icon(Icons.arrow_right),
  //                   onPressed: () => _incrementCounter(),
  //                 )
  //               ],
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             ),
  //             bottom: TabBar(
  //                 isScrollable: true,
  //                 unselectedLabelColor: Colors.white.withOpacity(0.3),
  //                 indicatorColor: Colors.white,
  //                 tabs: [
  //                   tabBar('Pt Details'),
  //                   tabBar('Summary'),
  //                   // tabBar('RER'),
  //                   // tabBar('Vitals'),
  //                   // tabBar('Temp'),
  //                   // tabBar('F/C'),
  //                   // tabBar('ECG'),
  //                   // tabBar('CC'),
  //                   // tabBar('Images'),
  //                   // tabBar('Drugs'),
  //                   // tabBar('I/O'),
  //                   // tabBar('Generate'),
  //                   // tabBar('Preview'),
  //                   // tabBar('Download'),
  //                 ]),
  //           ),
  //           body: TabBarView(children: <Widget>[
  //             PtDetails(),
  //             Summary(),
  //             // RerPdfDownload(upLevelPdf),
  //             // RerTab(),
  //             // VitalsChart(),
  //             // TempChart(),
  //             // FlowChart(),
  //             // Center(child: Text('ECG...')),
  //             // Center(child: Text('Culture, Cytology, HPE...')),
  //             // ImagingTab(),
  //             // DrugCharts(),
  //             // Center(child: Icon(Icons.monetization_on)),
  //             // Center(child: Text('Generate')),
  //             // DownloadTab(filePath: pdf == null ? null : pdf.path),
  //           ]),
  //         ),
  //       ));
  // }
}
