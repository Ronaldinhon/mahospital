import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/controllers/list_current_ward_pts_controller.dart';
import 'package:mahospital/helpers/reponsiveness.dart';
import 'package:mahospital/tabs/disc_ent.dart';
import 'package:mahospital/tabs/flow_chart.dart';
import 'package:mahospital/tabs/imaging_tab.dart';
import 'package:mahospital/tabs/int_ent.dart';
import 'package:mahospital/tabs/int_note.dart';
import 'package:mahospital/tabs/op_doc.dart';
import 'package:mahospital/tabs/pt_details.dart';
import 'package:mahospital/tabs/records.dart';
import 'package:mahospital/tabs/rer_pdf.dart';
import 'package:mahospital/tabs/rev_ent.dart';
import 'package:mahospital/tabs/summary.dart';
// import 'package:memodx/tabs/drug_charts.dart';
// import 'package:memodx/tabs/summary_pdf.dart';
// maybe not pdf if summary its needed
// import 'package:memodx/tabs/temp_chart.dart';
// import 'package:memodx/tabs/vitals_chart.dart';
import 'package:provider/provider.dart';

class PtScreen extends StatefulWidget {
  @override
  _PtScreenState createState() => _PtScreenState();
}

class _PtScreenState extends State<PtScreen> with TickerProviderStateMixin {
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
    ecController.tc1 = new TabController(length: 10, vsync: this);
    ecController.tc2 = new TabController(length: 10, vsync: this);
    ecController.tc3 = new TabController(length: 10, vsync: this);
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
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4)),
                          child: Icon(
                            Icons.arrow_left,
                            color: Colors.black,
                          ),
                          onPressed: () => _decrementCounter(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentWPLC.cbm.value.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentWPLC.cwpm.value.name,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                        ElevatedButton(
                          child: Icon(
                            Icons.arrow_right,
                            color: Colors.black,
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4)),
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
                              length: 10,
                              child: Column(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                    height: 50,
                                    width: _width1,
                                    child: TabBar(
                                        controller: ecController.tc1,
                                        isScrollable: true,
                                        unselectedLabelColor:
                                            Colors.white.withOpacity(0.3),
                                        indicatorColor: Colors.white,
                                        tabs: [
                                          tabBar('Pt Details'),
                                          tabBar('RER'),
                                          tabBar('Rev/Ent'),
                                          tabBar('Summary'),
                                          tabBar('Int Entry'),
                                          tabBar('Int Note'),
                                          tabBar('Disc Entry'),
                                          tabBar('Disc Doc'),
                                          tabBar('FlowChart'),
                                          tabBar('Imaging'),
                                        ]),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                        controller: ecController.tc1,
                                        children: <Widget>[
                                          PtDetails(),
                                          Records(
                                              ecController.tc1,
                                              ecController.itemScrollController,
                                              ecController
                                                  .itemPositionsListener),
                                          RevEnt(),
                                          RerPdf(),
                                          IntEnt(),
                                          IntNote(),
                                          DiscEnt(),
                                          OpDoc(),
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
                              length: 10,
                              child: Column(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(color: Colors.blue),
                                    height: 50,
                                    width: _width2,
                                    child: TabBar(
                                        controller: ecController.tc2,
                                        isScrollable: true,
                                        unselectedLabelColor:
                                            Colors.white.withOpacity(0.3),
                                        indicatorColor: Colors.white,
                                        tabs: [
                                          tabBar('Pt Details'),
                                          tabBar('RER'),
                                          tabBar('Rev/Ent'),
                                          tabBar('Summary'),
                                          tabBar('Int Entry'),
                                          tabBar('Int Note'),
                                          tabBar('Disc Entry'),
                                          tabBar('Disc Doc'),
                                          tabBar('FlowChart'),
                                          tabBar('Imaging'),
                                        ]),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                        controller: ecController.tc2,
                                        children: <Widget>[
                                          PtDetails(),
                                          Records(
                                              ecController.tc2,
                                              ecController
                                                  .itemScrollController1,
                                              ecController
                                                  .itemPositionsListener1),
                                          RevEnt(),
                                          RerPdf(),
                                          IntEnt(),
                                          IntNote(),
                                          DiscEnt(),
                                          OpDoc(),
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
              length: 10,
              child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4)),
                        child: Icon(
                          Icons.arrow_left,
                          color: Colors.black,
                        ),
                        onPressed: () => _decrementCounter(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentWPLC.cbm.value.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentWPLC.cwpm.value.name,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      ElevatedButton(
                        child: Icon(
                          Icons.arrow_right,
                          color: Colors.black,
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4)),
                        onPressed: () => _incrementCounter(),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                  ),
                  bottom: TabBar(
                      controller: ecController.tc3,
                      isScrollable: true,
                      unselectedLabelColor: Colors.white.withOpacity(0.3),
                      indicatorColor: Colors.white,
                      tabs: [
                        tabBar('Pt Details'),
                        tabBar('RER'),
                        tabBar('Rev/Ent'),
                        tabBar('Summary'),
                        tabBar('Int Entry'),
                        tabBar('Int Note'),
                        tabBar('Disc Entry'),
                        tabBar('Disc Doc'),
                        tabBar('FlowChart'),
                        tabBar('Imaging'),
                      ]),
                ),
                body:
                    TabBarView(controller: ecController.tc3, children: <Widget>[
                  PtDetails(),
                  Records(ecController.tc3, ecController.itemScrollController,
                      ecController.itemPositionsListener),
                  RevEnt(),
                  RerPdf(),
                  IntEnt(),
                  IntNote(),
                  DiscEnt(),
                  OpDoc(),
                  FlowChart(),
                  ImagingTab(),
                ]),
              ),
            ));
  }
}
