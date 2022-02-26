import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/dept_model.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:mahospital/widget/rer_card.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RevEnt extends StatefulWidget {
  @override
  _RevEntState createState() => _RevEntState();
}

class _RevEntState extends State<RevEnt> {
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

  Map<String, String> demoSC = {
    'yo': 'years old,',
    'MM': 'Malay Male',
    'CM': 'Chinese Male',
    'IM': 'Indian Male',
    'MF': 'Malay Female',
    'CF': 'Chinese Female',
    'IF': 'Indian Female',
  };

  Map<String, String> dxSC = {
    'Dx': 'Dx:',
    'IOL': 'IOL',
    'LPOL': 'Latent Phase of Labour',
    'APOL': 'Active Phase of Labour',
    'GDM': 'GDM',
    'PIH': 'PIH',
    'PROM': 'PROM',
    'PPROM': 'PPROM',
    'IUGR': 'IUGR',
    'SGA': 'SGA',
    'LGA': 'LGA',
    'ELRT': 'Elective LSCS for Refused TOLAC',
    'AMA': 'Advanced Maternal Age',
    'SMS': 'Single Mother Status',
    'LB': 'Late Booker',
    'AIP': 'Anaemia in Pregnancy',
    'Bthal': 'Beta Thalassemia',
    'PP': 'Placenta Preavia',
  };

  Map<String, String> pwSC = {
    'Pw': 'PW:',
    'FV': 'Fever',
    'SOB': 'SOB',
    'C.Pain': 'Chest Pain',
    'Palp': 'Palpitation',
    'Hemop': 'Hemoptysis',
    'Abd Pain': 'Abd Pain',
    'H.Urea': 'Hematuria',
  };

  Map<String, String> curSC = {
    'Cur': 'Currently',
    'well': 'Well',
    'nSOb': 'No SOB',
    'nCP': 'No Chest pain',
    'nPP': 'No Palpitation',
    'nAP': 'No ABd Pain',
  };
  Map<String, String> oeSC = {
    'Oe': 'OE: \n BP \n HR \n Temp \n',
  };

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
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Dept'),
                  style: TextStyle(color: Colors.black),
                  items: getHospDeptModel().map((DeptModel value) {
                    return DropdownMenuItem<String>(
                      value: value.id,
                      child: Text(value.name),
                    );
                  }).toList(),
                  value: ecController.deptId.value,
                  validator: (val) {
                    if (val!.trim().isEmpty) {
                      return 'Dept is required!';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    // setState(() => dept = val!);
                    ecController.deptId.value = val!;
                    print(ecController.deptId.value);
                  },
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
                                            // textStyleHighlight:
                                            //     TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                          subtitle: Text(
                                            "This is subtitle gjhgjgjggjgjgjhgjhgjgjhggjgjgjgjgjgjgjgjggjgjggjhgjgjgjjgjgjgjhgjhgjgjg",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () {
                                            // onSelected(option.toString());
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
                                  // ),
                                ));
                          },
                          // onSelected: (selectedString) {
                          //   print(selectedString);
                          // },
                          fieldViewBuilder: (context, controller, focusNode,
                              onEditingComplete) {
                            // this.controller = ecController.mainEditor;

                            return
                                // TextField(
                                //   controller: controller,
                                //   focusNode: focusNode,
                                //   onEditingComplete: onEditingComplete,
                                //   onChanged: (yes) => ecController.checkOnChange(),
                                //   decoration: InputDecoration(
                                //     border: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //       borderSide: BorderSide(color: Colors.grey[300]!),
                                //     ),
                                //     focusedBorder: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //       borderSide: BorderSide(color: Colors.grey[300]!),
                                //     ),
                                //     enabledBorder: OutlineInputBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //       borderSide: BorderSide(color: Colors.grey[300]!),
                                //     ),
                                //     hintText: "Search Something",
                                //     prefixIcon: Icon(Icons.search),
                                //   ),
                                // )
                                ConstrainedBox(
                              constraints: new BoxConstraints(
                                maxHeight: 200,
                              ),
                              child: SingleChildScrollView(
                                reverse: true,
                                child: TextFormField(
                                  focusNode: focusNode,
                                  controller: controller,
                                  key: ValueKey('entry'),
                                  onChanged: (yes) =>
                                      ecController.checkOnChange(),
                                  onEditingComplete: onEditingComplete,
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return 'Review/Entry cannot be empty!';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Review / Entry',
                                    contentPadding: const EdgeInsets.all(4.0),
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                ),
                              ),
                            );
                          },
                        )),
                // ConstrainedBox(
                //   constraints: new BoxConstraints(
                //     maxHeight: MediaQuery.of(context).size.height * 0.4,
                //   ),
                //   child: SingleChildScrollView(
                //       reverse: true,
                //       child: Autocomplete(
                //         optionsBuilder: (TextEditingValue textEditingValue) {
                //           print('triggered');
                //           var lastText =
                //               ecController.mainEditor.text.split(' ').last;
                //           if (lastText.isEmpty) {
                //             return const Iterable<String>.empty();
                //           } else {
                //             return deptScut.where((word) => word
                //                 .toLowerCase()
                //                 .contains(lastText.toLowerCase()));
                //           }
                //         },
                //         optionsViewBuilder:
                //             (context, Function(String) onSelected, options) {
                //           return Material(
                //             elevation: 4,
                //             child: ListView.separated(
                //               padding: EdgeInsets.zero,
                //               itemBuilder: (context, index) {
                //                 final option = options.elementAt(index);
                //                 return ListTile(
                //                   // title: Text(option.toString()),
                //                   title: SubstringHighlight(
                //                     text: option.toString(),
                //                     term: ecController.mainEditor.text
                //                         .split(' ')
                //                         .last,
                //                     textStyleHighlight:
                //                         TextStyle(fontWeight: FontWeight.w700),
                //                   ),
                //                   // subtitle: Text("This is subtitle"),
                //                   onTap: () {
                //                     onSelected(option.toString());
                //                   },
                //                 );
                //               },
                //               separatorBuilder: (context, index) => Divider(),
                //               itemCount: options.length,
                //             ),
                //           );
                //         },
                //         onSelected: (selectedString) {
                //           print(selectedString);
                //           ecController
                //               .insertText(selectedString.toString() + ' \n');
                //         },
                //         fieldViewBuilder: (context, controller, focusNode,
                //             onEditingComplete) {
                //           // this.controller = controller;
                //           return TextFormField(
                //             onEditingComplete: onEditingComplete,
                //             focusNode: ecController.fc1,
                //             key: ValueKey('entry'),
                //             decoration: InputDecoration(
                //               labelText: 'Review / Entry',
                //               contentPadding: const EdgeInsets.all(4.0),
                //             ),
                //             keyboardType: TextInputType.multiline,
                //             controller: ecController.mainEditor,
                //             maxLines: null,
                //           );
                //         },
                //       )),
                // ),
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

// ConstrainedBox(
//   constraints: new BoxConstraints(
//     maxHeight: 200,
//   ),
//   child: SingleChildScrollView(
//     reverse: true,
//     child:
//     TextFormField(
//       focusNode: ecController.fc1,
//       key: ValueKey('entry'),
//       decoration: InputDecoration(
//         labelText: 'Review / Entry',
//         contentPadding: const EdgeInsets.all(4.0),
//       ),
//       keyboardType: TextInputType.multiline,
//       controller: ecController.mainEditor,
//       maxLines: null,
//     ),
//   ),
// ),

// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: demoSC.keys.map((String head) {
//       return Padding(
//         padding: const EdgeInsets.all(2.0),
//         child: OutlinedButton(
//           child: Text(head),
//           onPressed: () =>
//               ecController.insertText(demoSC[head]! + ' \n'),
//         ),
//       );
//     }).toList(),
//   ),
// ),
// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: pwSC.keys.map((String head) {
//       return Padding(
//         padding: const EdgeInsets.all(2.0),
//         child: OutlinedButton(
//           child: Text(head),
//           onPressed: () =>
//               ecController.insertText(pwSC[head]! + ' \n'),
//         ),
//       );
//     }).toList(),
//   ),
// ),
// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: dxSC.keys.map((String head) {
//       return Padding(
//         padding: const EdgeInsets.all(2.0),
//         child: OutlinedButton(
//           child: Text(head),
//           onPressed: () =>
//               ecController.insertText(dxSC[head]! + ' \n'),
//         ),
//       );
//     }).toList(),
//   ),
// ),
// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: curSC.keys.map((String head) {
//       return Padding(
//         padding: const EdgeInsets.all(2.0),
//         child: OutlinedButton(
//           child: Text(head),
//           onPressed: () =>
//               ecController.insertText(curSC[head]! + ' \n'),
//         ),
//       );
//     }).toList(),
//   ),
// ),
// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     mainAxisSize: MainAxisSize.min,
//     children: oeSC.keys.map((String head) {
//       return Padding(
//         padding: const EdgeInsets.all(2.0),
//         child: OutlinedButton(
//           child: Text(head),
//           onPressed: () =>
//               ecController.insertText(oeSC[head]! + ' \n'),
//         ),
//       );
//     }).toList(),
//   ),
// ),
