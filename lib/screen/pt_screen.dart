import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/controllers/list_current_ward_pts_controller.dart';
import 'package:mahospital/helpers/reponsiveness.dart';
import 'package:mahospital/tabs/disc_ent.dart';
import 'package:mahospital/tabs/fc_pdf.dart';
import 'package:mahospital/tabs/flow_chart.dart';
import 'package:mahospital/tabs/imaging_tab.dart';
import 'package:mahospital/tabs/int_ent.dart';
import 'package:mahospital/tabs/int_note.dart';
import 'package:mahospital/tabs/disc_doc.dart';
import 'package:mahospital/tabs/pt_details.dart';
import 'package:mahospital/tabs/records.dart';
import 'package:mahospital/tabs/ward_pdf.dart';
import 'package:mahospital/tabs/rev_ent.dart';
import 'package:mahospital/tabs/summary.dart';
// import 'package:memodx/tabs/drug_charts.dart';
// import 'package:memodx/tabs/summary_pdf.dart';
// maybe not pdf if summary its needed
// import 'package:memodx/tabs/temp_chart.dart';
// import 'package:memodx/tabs/vitals_chart.dart';
import 'package:provider/provider.dart';

import '../tabs/fc_entry.dart';
import '../tabs/pt_sum.dart';
import '../tabs/vs_table.dart';
import 'edit_fc_param.dart';

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
                    leading: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    title: Row(
                      children: [
                        // ElevatedButton(
                        //   style: ButtonStyle(
                        //       backgroundColor: MaterialStateProperty.all<Color>(
                        //           Colors.white),
                        //       visualDensity:
                        //           VisualDensity(horizontal: -4, vertical: -4)),
                        //   child:
                        //   ,
                        //   onPressed: () => _decrementCounter(),
                        // )
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => _decrementCounter(),
                            child: Icon(
                              Icons.arrow_left,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentWPLC.cbm.value.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentWPLC.cwpm.value.name.capitalize!,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => _incrementCounter(),
                            child: Icon(
                              Icons.arrow_right,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        // ElevatedButton(
                        //   child: Icon(
                        //     Icons.arrow_right,
                        //     color: Colors.black,
                        //   ),
                        //   style: ButtonStyle(
                        //       backgroundColor: MaterialStateProperty.all<Color>(
                        //           Colors.white),
                        //       visualDensity:
                        //           VisualDensity(horizontal: -4, vertical: -4)),
                        //   onPressed: () => _incrementCounter(),
                        // )
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
                                          tabBar('Pt Sum'),
                                          tabBar('RER'),
                                          tabBar('Rev/Ent'),
                                          tabBar('Ward Sum'),
                                          // tabBar('Int Entry'),
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
                                          PtSum(),
                                          Records(
                                              ecController.tc1,
                                              ecController.itemScrollController,
                                              ecController
                                                  .itemPositionsListener,
                                              ecController.fc,
                                              ecController.searchCont,
                                              ecController.isSelected),
                                          RevEnt(),
                                          WardPdf(),
                                          // IntEnt(),
                                          IntNote(),
                                          DiscEnt(),
                                          DiscDoc(),
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
                                          tabBar('Pt Sum'),
                                          tabBar('RER'),
                                          tabBar('Rev/Ent'),
                                          tabBar('Ward Sum'),
                                          // tabBar('Int Entry'),
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
                                          PtSum(),
                                          Records(
                                              ecController.tc2,
                                              ecController
                                                  .itemScrollController1,
                                              ecController
                                                  .itemPositionsListener1,
                                              ecController.fc1,
                                              ecController.searchCont1,
                                              ecController.isSelected1),
                                          RevEnt(),
                                          WardPdf(),
                                          // IntEnt(),
                                          IntNote(),
                                          DiscEnt(),
                                          DiscDoc(),
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
                // appBar: AppBar(
                //   title: Row(
                //     children: [
                //       ElevatedButton(
                //         style: ButtonStyle(
                //             backgroundColor:
                //                 MaterialStateProperty.all<Color>(Colors.white),
                //             visualDensity:
                //                 VisualDensity(horizontal: -4, vertical: -4)),
                //         child: Icon(
                //           Icons.arrow_left,
                //           color: Colors.black,
                //         ),
                //         onPressed: () => _decrementCounter(),
                //       ),
                //       Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Text(
                //             currentWPLC.cbm.value.name,
                //             overflow: TextOverflow.ellipsis,
                //           ),
                //           Text(
                //             currentWPLC.cwpm.value.name.capitalize!,
                //             overflow: TextOverflow.ellipsis,
                //           )
                //         ],
                //       ),
                //       ElevatedButton(
                //         child: Icon(
                //           Icons.arrow_right,
                //           color: Colors.black,
                //         ),
                //         style: ButtonStyle(
                //             backgroundColor:
                //                 MaterialStateProperty.all<Color>(Colors.white),
                //             visualDensity:
                //                 VisualDensity(horizontal: -4, vertical: -4)),
                //         onPressed: () => _incrementCounter(),
                //       )
                //     ],
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     mainAxisSize: MainAxisSize.max,
                //   ),
                //   bottom: TabBar(
                //       controller: ecController.tc3,
                //       isScrollable: true,
                //       unselectedLabelColor: Colors.white.withOpacity(0.3),
                //       indicatorColor: Colors.white,
                //       tabs: [
                //         tabBar('Pt Details'),
                //         tabBar('Pt Sum'),
                //         tabBar('RER'),
                //         tabBar('Rev/Ent'),
                //         tabBar('Disc Entry'),
                //         tabBar('FlowChart'),
                //         tabBar('VsChart'),
                //         // tabBar('Int Entry'),
                //         tabBar('Int Note'),
                //         tabBar('Disc Doc'),
                //         tabBar('Imaging'),
                //       ]),
                // ),
                appBar: AppBar(
                  leading: GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: () => _decrementCounter(),
                            child: Container(
                              // alignment: Alignment.centerLeft, // no use
                                decoration: BoxDecoration(color: Colors.red),
                                child: Icon(
                                  Icons.arrow_circle_left,
                                  color: Colors.white,
                                  size: 32,
                                ))),
                      ),
                      Expanded(
                        flex: 15,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentWPLC.cbm.value.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentWPLC.cwpm.value.name.capitalize!,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                            onTap: () => _incrementCounter(),
                            child: Container(
                              // alignment: Alignment.centerRight,
                              decoration: BoxDecoration(color: Colors.red),
                              child: 
                              Icon(
                                Icons.arrow_circle_right,
                                color: Colors.white,
                                size: 32,
                              ),
                            )),
                      ),
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
                        tabBar('Pt Sum'),
                        tabBar('RER'),
                        tabBar('Rev/Ent'),
                        tabBar('Disc Entry'),
                        tabBar('FlowChart'),
                        tabBar('VsChart'),
                        // tabBar('Int Entry'),
                        tabBar('Int Note'),
                        tabBar('Disc Doc'),
                        tabBar('Imaging'),
                      ]),
                ),
                body:
                    TabBarView(controller: ecController.tc3, children: <Widget>[
                  PtDetails(),
                  !ecController.printingSum.value ? PtSum() : WardPdf(),
                  !ecController.printingRec.value
                      ? Records(
                          ecController.tc3,
                          ecController.itemScrollController,
                          ecController.itemPositionsListener,
                          ecController.fc,
                          ecController.searchCont,
                          ecController.isSelected)
                      : IntNote(),
                  RevEnt(),
                  !ecController.printingDisc.value ? DiscEnt() : DiscDoc(),
                  ecController.printingFC.value
                      ? FcPdf()
                      : ecController.entryFC.value
                          ? FcEntry()
                          : ecController.editFCparam.value
                              ? EditFcParam()
                              : FlowChart(),
                  VsTable(),
                  WardPdf(),
                  // IntEnt(),
                  IntNote(),
                  ImagingTab(),
                ]),
              ),
            ));
  }
}
