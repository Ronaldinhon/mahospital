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

class IntEnt extends StatefulWidget {
  @override
  _IntEntState createState() => _IntEntState();
}

class _IntEntState extends State<IntEnt> {
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

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final now = new DateTime.now();
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
        var nowTime = DateTime(now.year, now.month, now.day, selectedTime.hour,
            selectedTime.minute);
        currentWPLC.timeCont.text = DateFormat('kk:mm').format(nowTime);
        // pickedS.hour.toString() + ':' + pickedS.minute.toString();
      });
    else
      setState(() {
        currentWPLC.timeCont.text = DateFormat('kk:mm').format(now);
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
                  key: ValueKey('date'),
                  controller: currentWPLC.dateCont,
                  // controller: _dobController,
                  keyboardType: TextInputType.datetime,
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
                  controller: currentWPLC.timeCont,
                  keyboardType: TextInputType.datetime,
                  validator: RequiredValidator(errorText: 'Time is required'),
                  decoration: InputDecoration(
                    labelText: 'Time',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                LayoutBuilder(
                    builder: (context, constraintss) => RawAutocomplete(
                          textEditingController: ecController.mainEditor,
                          focusNode: ecController.fc1,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            // print('triggered');
                            var editText = textEditingValue.text;
                            if (editText.isEmpty ||
                                editText.substring(editText.length - 1) ==
                                    ' ') {
                              return const Iterable<String>.empty();
                            } else {
                              var lastText = editText.split(' ').last;
                              return deptScut.where((word) => word
                                  .toLowerCase()
                                  .contains(lastText.toLowerCase()));
                            }
                          },
                          optionsViewBuilder:
                              (context, Function(String) onSelected, options) {
                            return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(4.0)),
                                  ),
                                  // elevation: 4,
                                  child:
                                      // Obx(
                                      //   () =>
                                      Container(
                                    width: constraintss.biggest.width,
                                    // constraints: BoxConstraints(
                                    //     maxWidth: constraints.biggest.width),
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          // title: Text(option.toString()),
                                          dense: true,
                                          title: SubstringHighlight(
                                            text: option.toString(),
                                            term: ecController.mainEditor.text
                                                .split(' ')
                                                .last,
                                          ),
                                          subtitle: Text(
                                            "This is subtitle gjhgjgjggjgjgjhgjhgjgjhggjgjgjgjgjgjgjgjggjgjggjhgjgjgjjgjgjgjhgjhgjgjg",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () {
                                            ecController.replaceInsert(
                                                option.toString());
                                          },
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          Divider(),
                                      itemCount: options.length,
                                    ),
                                  ),
                                ));
                          },
                          fieldViewBuilder: (context, controller, focusNode,
                              onEditingComplete) {
                            return ConstrainedBox(
                              constraints: new BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: SingleChildScrollView(
                                reverse: true,
                                child: TextFormField(
                                  focusNode: focusNode,
                                  controller: currentWPLC.yeah,
                                  key: ValueKey('entry'),
                                  // onChanged: (yes) =>
                                  //     ecController.checkOnChange(),
                                  onEditingComplete: onEditingComplete,
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return 'Review/Entry cannot be empty!';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Integrated Entry',
                                    contentPadding: const EdgeInsets.all(4.0),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                ),
                              ),
                            );
                          },
                        )),
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
