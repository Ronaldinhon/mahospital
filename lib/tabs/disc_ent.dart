import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:mahospital/widget/rer_card.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';

class DiscEnt extends StatefulWidget {
  @override
  _DiscEntState createState() => _DiscEntState();
}

class _DiscEntState extends State<DiscEnt> {
  late String uid;

  final List<String> deptShortcut = [
    '',
    'Med',
    'Surg',
    'O+G',
    'Peads',
    'Ortho',
  ];

  final List<String> deptScut = [
    'Med',
    'Surg',
    'O+G',
    'Peads',
    'Ortho',
  ];

  String dept = '';

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    super.initState();
  }

  Map<String, String> curSC = {
    'pt well':
        'Currently pt well\nGCS full\nUnder room air, no SOB, no chest pain, no palpitation\nNo abd pain',
    'oe': 'OE: \n BP \n HR \n Temp \n',
  };

  DateTime selectedDate = DateTime.now();

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
        currentWPLC.dateCont.text = DateFormat('dd/MM/yyyy').format(picked);
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
        currentWPLC.timeCont.text =
            pickedS.hour.toString() + ':' + pickedS.minute.toString();
      });
  }

  final _formKey = GlobalKey<FormState>();
  final entryCol =
      wardPtRef.doc(currentWPLC.cwpm.value.id).collection('entries').doc('1');
  late String dateInUTC;
  late Map mapEntry;

  void saveEntry() async {
    if (_formKey.currentState!.validate()) {
      dateInUTC = DateTime.now().millisecondsSinceEpoch.toString();
      mapEntry = {
        'byId': uid,
        'dept': ecController.deptId.value.trim(),
        'data': ecController.mainEditor.text.trim(),
        'createdAt': dateInUTC,
        'updatedAt': dateInUTC
      };
      ecController.savingEntry.value = true;
      _formKey.currentState!.save();
      DocumentSnapshot eSS = await entryCol.get();
      // String dateInUTC = DateTime(selectedDate.year, selectedDate.month,
      //         selectedDate.day, selectedTime.hour, selectedTime.minute)
      //     .millisecondsSinceEpoch
      //     .toString();
      if (eSS.exists) {
        Map<String, dynamic> entries = eSS.get('entries');
        entries[dateInUTC] = mapEntry;

        entryCol.update({'entries': entries}).then((v) {
          // i think must put in function next time (below update active dept)
          if (!currentWPLC.cwpm.value.activeDepts
              .contains(ecController.deptId.value.trim())) {
            var listDept = currentWPLC.cwpm.value.activeDepts;
            listDept.add(ecController.deptId.value.trim());
            wardPtRef
                .doc(currentWPLC.cwpm.value.id)
                .update({'deptIds': listDept});
          }
          currentWPLC.cwpm.value.entries[dateInUTC] = mapEntry;
          currentWPLC.cwpm.value.latestEntry = mapEntry;
          ecController.deptId.value = '';
          ecController.mainEditor.text = '';
          ecController.savingEntry.value = false;
          // need to update record tab? - need
          // below also same
        });
      } else {
        entryCol.set({
          'entries': {dateInUTC: mapEntry}
        }).then((v) {
          updateLocalController();
        });
      }
    }
  }

  void updateLocalController() {
    var wmph = currentWPLC.cwpm.value; // wardModelPlaceHolder
    if (!wmph.activeDepts.contains(dept)) {
      var listDept = wmph.activeDepts;
      listDept.add(dept);
      wardPtRef.doc(wmph.id).update({'deptIds': listDept});
    }
    if (wmph.rerIni)
      wmph.entries[dateInUTC] = mapEntry;
    else
      wmph.entries = {dateInUTC: mapEntry};
    wmph.latestEntry = mapEntry;
    wmph.rerIni = true;
    dept = '';
    ecController.mainEditor.text = '';
    ecController.savingEntry.value = false;
    userListController.addUser(userController.user);
  }

  late TextEditingController controller;

  List<DeptModel> getHospDeptModel() {
    List<DeptModel> hdml =
        deptListController.currentHospDepts(currentWPLC.cwpm.value.hospId);
    hdml.add(DeptModel('', ''));
    return hdml;
  }

// TextEditingController dnameCont = TextEditingController(text: '');
//   TextEditingController drnCont = TextEditingController(text: '');
//   TextEditingController dicCont = TextEditingController(text: '');
//   TextEditingController dageCont = TextEditingController(text: '');
//   TextEditingController ddobCont = TextEditingController(text: '');
//   TextEditingController daddCont = TextEditingController(text: '');
//   TextEditingController dsexCont = TextEditingController(text: '');
//   TextEditingController ddoaCont = TextEditingController(text: '');
//   TextEditingController ddodCont = TextEditingController(text: '');
//   TextEditingController dwardCont = TextEditingController(text: '');
//   TextEditingController dfdxCont = TextEditingController(text: '');
//   TextEditingController dfupCont = TextEditingController(text: '');
//   TextEditingController dnoteCont = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(
                  height: 4,
                ),
                TextFormField(
                  key: ValueKey('name'),
                  controller: currentWPLC.dnameCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  key: ValueKey('rn'),
                  controller: currentWPLC.drnCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'RN',
                  ),
                ),
                TextFormField(
                  key: ValueKey('ic'),
                  controller: currentWPLC.dicCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'ic',
                  ),
                ),
                TextFormField(
                  key: ValueKey('age'),
                  controller: currentWPLC.dageCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'age',
                  ),
                ),
                TextFormField(
                  key: ValueKey('dob'),
                  controller: currentWPLC.ddobCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'dob',
                  ),
                ),
                TextFormField(
                  key: ValueKey('sex'),
                  controller: currentWPLC.dsexCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'sex',
                  ),
                ),
                TextFormField(
                  key: ValueKey('add'),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: currentWPLC.daddCont,
                  // keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'add',
                  ),
                ),
                TextFormField(
                  key: ValueKey('doa'),
                  controller: currentWPLC.ddoaCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'doa',
                  ),
                ),
                TextFormField(
                  key: ValueKey('dod'),
                  controller: currentWPLC.ddodCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'dod',
                  ),
                ),
                TextFormField(
                  key: ValueKey('ward'),
                  controller: currentWPLC.dwardCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'ward',
                  ),
                ),
                TextFormField(
                  key: ValueKey('fdx'),
                  controller: currentWPLC.dfdxCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'fdx',
                  ),
                ),
                TextFormField(
                  key: ValueKey('fup'),
                  controller: currentWPLC.dfupCont,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: 'fup',
                  ),
                ),
                TextFormField(
                  key: ValueKey('dnote'),
                  controller: currentWPLC.dnoteCont,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'dnote',
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: 4,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: curSC.keys.map((String head) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: OutlinedButton(
                          child: Text(head),
                          onPressed: () {
                            currentWPLC.yeah.text += curSC[head].toString();
                            setState(() {});
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                !ecController.savingEntry.value
                    ? ElevatedButton(
                        child: Text('Save'),
                        onPressed: () => saveEntry(),
                      )
                    : CircularProgressIndicator(),
                SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
        )));
  }
}
