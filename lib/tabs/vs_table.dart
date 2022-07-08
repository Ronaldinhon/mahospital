import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:intl/intl.dart';

class VsTable extends StatefulWidget {
  @override
  _VsTableState createState() => _VsTableState();
}

class _VsTableState extends State<VsTable> {
  List<String> vitalsTitle = ['HR', 'BP', 'RR', 'O2', 'Temp', 'Notes'];
  List<String> vitals = [
    '200/80',
    '200',
    '200',
    '37',
    'VVVVVVVV',
    '----------------------------------------------------------------------' // this is 70 char
  ];
  List<String> date = [
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
    '11/11/2021',
  ];
  List<String> time = [
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
    '18:18H',
  ];

  late ScrollController sctrl;
  int initialRows = 8;
  double offset = 0;
  List<Team> ff = [];

  @override
  void initState() {
    sctrl = ScrollController(keepScrollOffset: true);
    sctrl.addListener(slistener);
    ff = teamsData;
    super.initState();
  }

  void slistener() {
    if (sctrl.offset >= sctrl.position.maxScrollExtent) {
      // offset = sctrl.offset;
      setState(() {
        ff += teamsData;
        // sctrl = ScrollController(keepScrollOffset: true);
        // sctrl.addListener(slistener);
      }); // just commented 3 lines
    }
  }

  @override
  void dispose() {
    sctrl.dispose();
    super.dispose();
  }

  Widget _getTitleItemWidget(String vitalString) {
    return Container(
      height: 90,
      width: vitalString == 'Notes'
          ? 260
          : vitalString == 'O2'
              ? 100
              : 60,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        ),
      ),
      child: Center(
        child: Text(vitalString),
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    List<Widget> sth = [];
    sth.add(Container(
      padding: EdgeInsets.all(5),
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
        ),
      ),
      // padding: EdgeInsets.all(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
        ],
      ),
    ));
    vitalsTitle.forEach((dt) {
      sth.add(_getTitleItemWidget(dt));
    });
    return sth;
  }

  Widget _generateFirstColumn(BuildContext context, int index) {
    return Material(
      child: Container(
          padding: EdgeInsets.all(3),
          width: 90,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                splashColor: Colors.red,
                onTap: () => addVsValue(time[index], index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(date[index]),
                    Text(time[index]),
                  ],
                ),
              ),
              // IconButton(
              //     icon: Icon(Icons.edit, color: Colors.black, size: 18),
              //     onPressed: () => print('edit'),
              //     visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
              ElevatedButton(
                child: Icon(Icons.edit, color: Colors.black, size: 18),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.all(0),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
                onPressed: () => print('edit'),
              ),
            ],
          )),
    );
  }

  void addVsValue(String head, int index) {
    // List<String> ixVals = [];
    // for (var ii in ecController.ascNum) {
    //   if (ecController.wer[index][ii].isNotEmpty)
    //     ixVals.add(ecController.wer[index][ii]);
    // }
    String oyster = '\n$head ' + vitals.join(" // ");
    ecController.mainEditor.text += oyster;
  }

  Widget _generateRightHandSideRow(BuildContext context, int index) {
    List<Widget> rowChildren = [];
    var count = 0;
    for (var ii in vitals) {
      count++;
      rowChildren.add(Container(
        padding: EdgeInsets.all(5),
        child: Text(ii),
        width: count == 6
            ? 260
            : count == 5
                ? 100
                : 60,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
          ),
        ),
        alignment: Alignment.center,
      ));
    }
    return Row(
      children: rowChildren,
    );
  }

  late DocumentReference fc;
  Future<List> getFlowChartData(String id) async {
    // bloodParam.forEach((bp) => ecController.masterMap[bp] = []);
    // fc = wardPtRef.doc(id).collection('flowCharts').doc('1');
    // DocumentSnapshot fcSS = await fc.get();
    // if (fcSS.exists) {
    //   Map bloodMap = fcSS.get('bloods');
    //   ecController.orderedDateTime = bloodMap.keys.toList();
    //   ecController.numberOfDays = ecController.orderedDateTime.length;
    //   ecController.ascNum = List.generate(ecController.numberOfDays, (i) => i);
    //   ecController.orderedDateTime.sort((a, b) => int.parse(b)
    //       .compareTo(int.parse(a))); // reversed - actually no need int.parse
    //   for (var odt in ecController.orderedDateTime) {
    //     Map bloodValues = bloodMap[odt];
    //     bloodParam.forEach((bp) {
    //       ecController.masterMap[bp]!.add(bloodValues[bp]);
    //     });
    //   }
    //   List<List<String>> masterList = [];
    //   for (var bpp in bloodParam) {
    //     masterList.add(ecController.masterMap[bpp]!);
    //   }
    //   ecController.wer = masterList;
    //   return masterList;
    // } else {
    //   List<List<String>> emptyList = [];
    //   bloodParam.forEach((bp) => emptyList.add(['']));
    //   ecController.wer = emptyList;
    //   ecController.numberOfDays = 0;
    //   return [];
    // }
    return [];
  }

  HDTRefreshController _hdtRefreshController = HDTRefreshController();

  List<Team> teamsData = [
    Team(
        position: 1,
        name: 'Atletico',
        points: 11,
        played: 5,
        won: 3,
        drawn: 2,
        lost: 0,
        against: 4,
        gd: 3),
    Team(
        position: 2,
        name: 'Real',
        points: 10,
        played: 4,
        won: 3,
        drawn: 1,
        lost: 0,
        against: 6,
        gd: 7),
    Team(
        position: 3,
        name: 'Valencia',
        points: 10,
        played: 4,
        won: 3,
        drawn: 2,
        lost: 0,
        against: 2,
        gd: 7),
    Team(
        position: 4,
        name: 'Athletic',
        points: 9,
        played: 5,
        won: 2,
        drawn: 3,
        lost: 0,
        against: 1,
        gd: 3),
    Team(
        position: 5,
        name: 'Real',
        points: 9,
        played: 4,
        won: 3,
        drawn: 0,
        lost: 1,
        against: 4,
        gd: 2),
    Team(
        position: 6,
        name: 'Osasuna',
        points: 8,
        played: 5,
        won: 2,
        drawn: 2,
        lost: 1,
        against: 6,
        gd: 0),
    Team(
        position: 7,
        name: 'Mallorca',
        points: 8,
        played: 5,
        won: 2,
        drawn: 2,
        lost: 1,
        against: 3,
        gd: 0),
    Team(
        position: 8,
        name: 'Sevilla',
        points: 7,
        played: 3,
        won: 2,
        drawn: 1,
        lost: 0,
        against: 1,
        gd: 4),
    Team(
        position: 9,
        name: 'Rayo',
        points: 7,
        played: 5,
        won: 2,
        drawn: 1,
        lost: 2,
        against: 5,
        gd: 3),
    Team(
        position: 10,
        name: 'Barcelona',
        points: 7,
        played: 3,
        won: 2,
        drawn: 1,
        lost: 0,
        against: 4,
        gd: 3),
    Team(
        position: 11,
        name: 'Elche',
        points: 6,
        played: 5,
        won: 1,
        drawn: 3,
        lost: 1,
        against: 3,
        gd: 0),
    Team(
        position: 12,
        name: 'Real',
        points: 5,
        played: 4,
        won: 1,
        drawn: 2,
        lost: 1,
        against: 4,
        gd: 0),
    Team(
        position: 13,
        name: 'Cadiz',
        points: 5,
        played: 5,
        won: 1,
        drawn: 2,
        lost: 2,
        against: 8,
        gd: -2),
    Team(
        position: 14,
        name: 'Villarreal',
        points: 4,
        played: 4,
        won: 0,
        drawn: 4,
        lost: 0,
        against: 2,
        gd: 0),
    Team(
        position: 15,
        name: 'Levante',
        points: 4,
        played: 5,
        won: 0,
        drawn: 4,
        lost: 1,
        against: 7,
        gd: -1),
    Team(
        position: 16,
        name: 'Espanyol',
        points: 2,
        played: 4,
        won: 0,
        drawn: 2,
        lost: 2,
        against: 3,
        gd: -2),
    Team(
        position: 17,
        name: 'Granada',
        points: 2,
        played: 4,
        won: 0,
        drawn: 2,
        lost: 2,
        against: 7,
        gd: -5),
    Team(
        position: 18,
        name: 'Celta',
        points: 1,
        played: 5,
        won: 0,
        drawn: 1,
        lost: 4,
        against: 10,
        gd: -6),
    Team(
        position: 19,
        name: 'Getafe',
        points: 0,
        played: 5,
        won: 0,
        drawn: 0,
        lost: 5,
        against: 8,
        gd: -7),
    Team(
        position: 20,
        name: 'Alaves',
        points: 0,
        played: 4,
        won: 0,
        drawn: 0,
        lost: 4,
        against: 10,
        gd: -9),
  ];

  Expanded rightSide() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.green[100]),
            columnSpacing: 15,
            dataRowHeight: 75,
            horizontalMargin: 10,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            columns: [
              DataColumn(
                  label: SizedBox(
                      width: 60, child: Center(child: Text('Points')))),
              DataColumn(label: Text('Won')),
              DataColumn(label: Text('Lost')),
              DataColumn(label: Text('Drawn')),
              DataColumn(
                  label: SizedBox(
                      width: 110, child: Center(child: Text('Against')))),
              DataColumn(
                  label:
                      SizedBox(width: 260, child: Center(child: Text('GD')))),
            ],
            rows: [
              ...ff.map((team) => DataRow(
                    cells: [
                      DataCell(Container(
                          width: 60,
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            team.points.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                      DataCell(Container(
                          alignment: AlignmentDirectional.center,
                          child: Text(team.won.toString()))),
                      DataCell(Container(
                          alignment: AlignmentDirectional.center,
                          child: Text(team.lost.toString()))),
                      DataCell(Container(
                          alignment: AlignmentDirectional.center,
                          child: Text(team.drawn.toString()))),
                      DataCell(Container(
                          width: 110,
                          alignment: AlignmentDirectional.center,
                          child: Text(team.against.toString()))),
                      DataCell(Container(
                          width: 260,
                          alignment: AlignmentDirectional.center,
                          child: Text(team.gd.toString()))),
                    ],
                  ))
            ]),
      ),
    );
  }

  DataTable leftSide() {
    return DataTable(
      columnSpacing: 0,
      headingRowColor: MaterialStateProperty.all(Colors.green[300]),
      dataRowHeight: 75,
      horizontalMargin: 10,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
      columns: [
        DataColumn(label: Text('Team')),
      ],
      rows: [
        ...ff.map((team) => DataRow(
              cells: [
                DataCell(Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Column(
                    children: [
                      Text(date[1]),
                      Text(time[1]),
                      ElevatedButton(
                        child: Icon(Icons.edit, color: Colors.black, size: 18),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4)),
                        onPressed: () => print('edit'),
                      ),
                    ],
                  ),
                )
                    //   Text(
                    //   '${team.position.toString()}  ${team.name}',
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // )
                    ),
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: sctrl,
            child: Row(
              children: [
                leftSide(),
                rightSide(),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class Team {
  Team({
    required this.position,
    required this.name,
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.against,
    required this.gd,
  });

  final int position;
  final String name;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int against;
  final int gd;
}

// String.fromCharCode(0x2B) +

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:mahospital/constants/controllers.dart';
// import 'package:mahospital/models/bed_model.dart';
// import 'package:native_pdf_view/native_pdf_view.dart' as nat;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pluto_grid/pluto_grid.dart';
// import 'package:printing/printing.dart';
// // import 'package:flutter_downloader/flutter_downloader.dart';
// // import 'package:permission_handler/permission_handler.dart';

// class VsTable extends StatefulWidget {
//   // final Function(File file, BuildContext context) upLevelPdf;
//   VsTable();
//   @override
//   _VsTableState createState() => _VsTableState();
// }

// class _VsTableState extends State<VsTable> {
//   final List<PlutoColumn> columns = <PlutoColumn>[
//     PlutoColumn(
//       title: 'Id',
//       field: 'id',
//       type: PlutoColumnType.text(),
//     ),
//     PlutoColumn(
//       title: 'Name',
//       field: 'name',
//       type: PlutoColumnType.text(),
//     ),
//     PlutoColumn(
//       title: 'Age',
//       field: 'age',
//       type: PlutoColumnType.number(),
//     ),
//     PlutoColumn(
//       title: 'Role',
//       field: 'role',
//       type: PlutoColumnType.select(<String>[
//         'Programmer',
//         'Designer',
//         'Owner',
//       ]),
//     ),
//     PlutoColumn(
//       title: 'Joined',
//       field: 'joined',
//       type: PlutoColumnType.date(),
//     ),
//     PlutoColumn(
//       title: 'Working time',
//       field: 'working_time',
//       type: PlutoColumnType.time(),
//     ),
//   ];

//   final List<PlutoRow> rows = [
//     PlutoRow(
//       cells: {
//         'id': PlutoCell(value: 'user1'),
//         'name': PlutoCell(value: 'Mike'),
//         'age': PlutoCell(value: 20),
//         'role': PlutoCell(value: 'Programmer'),
//         'joined': PlutoCell(value: '2021-01-01'),
//         'working_time': PlutoCell(value: '09:00'),
//       },
//     ),
//     PlutoRow(
//       cells: {
//         'id': PlutoCell(value: 'user2'),
//         'name': PlutoCell(value: 'Jack'),
//         'age': PlutoCell(value: 25),
//         'role': PlutoCell(value: 'Designer'),
//         'joined': PlutoCell(value: '2021-02-01'),
//         'working_time': PlutoCell(value: '10:00'),
//       },
//     ),
//     PlutoRow(
//       cells: {
//         'id': PlutoCell(value: 'user3'),
//         'name': PlutoCell(
//             value: 'Suzi Mizuno Myuki Sanwa Sensei arigato dai uki des'),
//         'age': PlutoCell(value: 40),
//         'role': PlutoCell(value: 'Owner'),
//         'joined': PlutoCell(value: '2021-03-01'),
//         'working_time': PlutoCell(value: '11:00'),
//       },
//     ),
//   ];

//   /// columnGroups that can group columns can be omitted.
//   final List<PlutoColumnGroup> columnGroups = [
//     PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
//     PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
//     PlutoColumnGroup(title: 'Status', children: [
//       PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
//       PlutoColumnGroup(title: 'Etc.', fields: ['joined', 'working_time']),
//     ]),
//   ];

//   late final PlutoGridStateManager stateManager;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//       return Container(
//         height: constraints.maxHeight,
//         child: PlutoGrid(
//           columns: columns,
//           rows: rows,
//           columnGroups: columnGroups,
//           onLoaded: (PlutoGridOnLoadedEvent event) {
//             stateManager = event.stateManager;
//           },
//           onChanged: (PlutoGridOnChangedEvent event) {
//             print(event);
//           },
//           configuration: const PlutoGridConfiguration(
//             enableColumnBorder: true,
//           ),
//         ),
//       );
//     });
//   }
// }
