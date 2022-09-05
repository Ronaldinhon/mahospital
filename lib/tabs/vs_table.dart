// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:intl/intl.dart';

class VsTable extends StatefulWidget {
  @override
  _VsTableState createState() => _VsTableState();
}

class _VsTableState extends State<VsTable> {
  List<String> vitalsTitle = [
    'HR/min', 'SYS/mmHg', 'DIA/mmHg', 'RR/min', 'SpO2', 'Temp', //'Notes'
  ];
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
  ];
  List<String> time = [
    '18:18H',
  ];

  late ScrollController sctrl;
  int initialRows = 8;
  double offset = 0;
  List<Team> ff = [];
  Map sendDataMap = {};
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final dobCont = TextEditingController();
  final timeCont = TextEditingController();

  void saveData() {}

  @override
  void initState() {
    sctrl = ScrollController(keepScrollOffset: true);
    sctrl.addListener(slistener);
    ff = teamsData;
    vitalsTitle.asMap().forEach((i, v) => vsList.add(
        VsTextField(v, sendDataMap, saveData)));
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
    dobCont.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    print(dobCont.text);
    print(DateFormat.Hms().format(selectedDate));
    timeCont.text = DateFormat.jm().format(selectedDate); 
    // selectedTime.hour.toString() + ':' + selectedTime.minute.toString(); // get hour and minute and put into date time
    super.initState();
  }

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

  void addVsValue(String head, int index) {
    // List<String> ixVals = [];
    // for (var ii in ecController.ascNum) {
    //   if (ecController.wer[index][ii].isNotEmpty)
    //     ixVals.add(ecController.wer[index][ii]);
    // }
    String oyster = '\n$head ' + vitals.join(" // ");
    ecController.mainEditor.text += oyster;
  }

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
                      width: 60, child: Center(child: Text('HR')))),
              DataColumn(label: Text('RR')),
              DataColumn(label: Text('SpO2')),
              DataColumn(label: Text('Temp')),
              DataColumn(
                  label: SizedBox(
                      width: 110, child: Center(child: Text('BP')))),
              DataColumn(
                  label:
                      SizedBox(width: 260, child: Center(child: Text('Notes')))),
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
                      Text(date[0]),
                      Text(time[0]),
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

  List<VsTextField> vsList = [];

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //     future: buildList(),
    //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapShot) {
    //       if (snapShot.connectionState == ConnectionState.done) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.bottom,
              isAlwaysShown: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(top: 7, left: 5, right: 5, bottom: 4),
                      width: 180,
                      child: TextFormField(
                        key: ValueKey('date'),
                        controller: dobCont,
                        readOnly: true,
                        validator:
                            RequiredValidator(errorText: 'Date is required'),
                        decoration: InputDecoration(
                          isDense: true,
                          // contentPadding:
                          //     EdgeInsets.zero,
                          labelText: 'Date',
                          prefixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
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
                        width: 160,
                        child: TextFormField(
                          key: ValueKey('time'),
                          controller: timeCont,
                          readOnly: true,
                          validator:
                              RequiredValidator(errorText: 'Time is required'),
                          decoration: InputDecoration(
                            isDense: true,
                            // contentPadding:
                                // EdgeInsets.zero,
                            labelText: 'Time',
                            prefixIcon: IconButton(
                              icon: Icon(Icons.access_time),
                              onPressed: () => _selectTime(context),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                          ),
                        )),
                    ...vsList,
                    Container(
                      // constraints: BoxConstraints(maxWidth: 50), // why cant use ConstrainedBox ??
                      padding:
                          EdgeInsets.only(top: 7, left: 5, right: 5, bottom: 4),
                      width: 200,
                      child: TextFormField(
                        maxLines: 1,
                        // maxLength: 70, // can be way more ba
                        // controller: controller,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1.0),
                            ),
                            labelText: 'Notes',
                            prefixIcon: IconButton(
                              icon: Icon(Icons.save),
                              onPressed: () {},
                            )),
                        // onSaved: (val) {
                        //   if (val != null) vsMap[paramName] = val;
                        // },
                        onChanged: (val) => print(val),
                      ),
                    )
                  ],
                ),
                // ),
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
    //   } else {
    //     return Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   }
    // });
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

class VsTextField extends StatelessWidget {
  final String paramName;
  final Map vsMap;
  final controller = TextEditingController();
  final void Function() saveFn;

  void clearValue() {
    controller.clear();
  }

  VsTextField(this.paramName, this.vsMap, this.saveFn);

  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: BoxConstraints(maxWidth: 50), // why cant use ConstrainedBox ??
      padding: EdgeInsets.only(top: 7, left: 5, right: 5, bottom: 4),
      width: 130,
      child: TextFormField(
        maxLines: 1,
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          // contentPadding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          labelText: paramName,
        ),
        onSaved: (val) {
          if (val != null) vsMap[paramName] = val;
        },
        onChanged: (val) => print(val),
      ),
    );
  }
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
