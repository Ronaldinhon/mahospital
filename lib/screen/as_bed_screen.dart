// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:mahospital/models/bed_model.dart';
// import 'package:mahospital/constants/firebase.dart';

// class AsBedScreen extends StatefulWidget {
//   final String wardId;
//   final List<BedModel> localBedModels;

//   AsBedScreen(this.wardId, this.localBedModels);
//   @override
//   _AsBedScreenState createState() => _AsBedScreenState();
// }

// class _AsBedScreenState extends State<AsBedScreen> {
//   // bool _bedIsLoading = false;
//   final _formKey = GlobalKey<FormState>();
//   late String uid;
//   late String errorMessage;
//   // Future<QuerySnapshot<Object>> future;

//   DocumentSnapshot<Object> ward;
//   QuerySnapshot<Object> localBeds;
//   List<QueryDocumentSnapshot<Object>> bedDocs;

//   List<dynamic> bedIds = [];
//   List<String> bedNames = [];
//   List<bool> activeList = [];
//   int counter = 0;

//   List<String> errorList = [];

//   @override
//   void initState() {
//     uid = FirebaseAuth.instance.currentUser.uid;
//     future = getDeptAndBed();
//     awaitLocalBeds();
//     print('laskjl');
//     super.initState();
//   }

//   void awaitLocalBeds() async {
//     localBeds = await future;
//     bedDocs = localBeds.docs;
//     if (bedIds != null)
//       bedIds.asMap().forEach((index, bed) {
//         var wBed = bedDocs?.firstWhere((bed) => bed.id == bedIds[index],
//             orElse: () => null);
//         bedNames.add(wBed['name']);
//         activeList.add(wBed['active']);
//       });
//   }

//   Future<QuerySnapshot<Object>> getDeptAndBed() async {
//     Future<QuerySnapshot<Object>> st =
//         wardRef.doc(widget.wardId).get().then((qward) {
//       ward = qward;
//       bedIds = ward['bedIdList'];
//       return bedRef.where('wardId', isEqualTo: qward.id).get();
//     });
//     return st;
//   }

//   void updateWardBed() {
//     _onLoading();
//     if (bedIds.isNotEmpty)
//       createBed(0);
//     else
//       _onLoadingDone();
//     // bedIds.asMap().forEach((index, bedId) {
//     //   if (bedId.isEmpty) {
//     //     createBed(index);
//     //   } else {
//     //     updateBed(index);
//     //   }
//     // });

//     // bedIds.removeWhere((value) => value == '');
//     // wardRef.doc(widget.wardId).update({'bedIdList': bedIds});
//     // if (errorList.isNotEmpty) {
//     //   message = Text('Error occured when updating bed ${errorList.join(', ')}');
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     SnackBar(
//     //       content: message,
//     //       backgroundColor: Theme.of(context).errorColor,
//     //     ),
//     //   );
//     // } else
//     //   Navigator.pop(context);
//   }

//   void _onLoading() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: new Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 new CircularProgressIndicator(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 new Text("Loading"),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//     // new Future.delayed(new Duration(seconds: 3), () {
//     //   Navigator.pop(context); //pop dialog
//     //   _login();
//     // });
//   }

//   void _onLoadingDone() {
//     Navigator.pop(context);
//     Text message = Text('All beds have been updated');
//     bedIds.removeWhere((value) => value == '');
//     wardRef.doc(widget.wardId).update({'bedIdList': bedIds});
//     if (errorList.isNotEmpty) {
//       message = Text('Error occured when updating bed ${errorList.join(', ')}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: message,
//           backgroundColor: Theme.of(context).errorColor,
//         ),
//       );
//     } else
//       Navigator.pop(context);
//   }

//   void createBed(int index) async {
//     String lbi = bedIds[index];
//     print(lbi);
//     try {
//       if (lbi.isEmpty)
//         await bedRef.add({
//           'name': bedNames[index],
//           'wardId': widget.wardId,
//           'deptId': ward['deptId'],
//           'hospId': ward['hospId'],
//           'occupied': false,
//           'ptId': null,
//           'ptDetails': null, //do we need this?
//           'active': true,
//           'lastUpdatedBy': uid,
//           'createdAt': DateTime.now().millisecondsSinceEpoch,
//           'updatedAt': DateTime.now().millisecondsSinceEpoch,
//         }).then((DocumentReference<Object> v) {
//           // print('create');
//           bedIds[index] = v.id;
//           if (index == bedIds.length - 1)
//             _onLoadingDone();
//           else
//             createBed(++index);
//         });
//       else
//         await bedRef.doc(bedIds[index]).update(
//             {'active': activeList[index], 'name': bedNames[index]}).then((v) {
//           print('update');
//           if (index == bedIds.length - 1)
//             _onLoadingDone();
//           else
//             createBed(++index);
//         });
//     } catch (error) {
//       print(error.toString());
//       errorList.add(bedNames[index]);
//       if (index == bedIds.length - 1)
//         _onLoadingDone();
//       else
//         createBed(++index);
//     }
//   }

//   void updateBed(int index) async {
//     // need to check first
//     try {
//       await bedRef.doc(bedIds[index]).update(
//           {'active': activeList[index], 'name': bedNames[index]}).then((v) {
//         if (index == bedIds.length - 1)
//           _onLoadingDone();
//         else
//           createBed(index++);
//       });
//     } catch (error) {
//       errorList.add(bedNames[index]);
//     }
//     if (index == bedIds.length - 1) _onLoadingDone();
//   }

//   void edit(int index) => showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             contentPadding: EdgeInsets.all(15.0),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     keyboardType: TextInputType.name,
//                     validator: (val) {
//                       if (val.trim().isEmpty) {
//                         return 'Bed name is required!';
//                       }
//                       return null;
//                     },
//                     // RequiredValidator(errorText: 'Bed name is required'),
//                     initialValue: bedNames[index],
//                     onSaved: (name) {
//                       setState(() => bedNames[index] = name.trim());
//                       print(bedNames);
//                     },
//                     // onFieldSubmitted: (_) => Navigator.of(context).pop(),
//                     // inputFormatters: [
//                     //   FilteringTextInputFormatter.allow(
//                     //       new RegExp(r"/^(\w+\s?)$/"))
//                     // ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       ElevatedButton(
//                           child: Text('Save'),
//                           onPressed: () {
//                             if (_formKey.currentState.validate()) {
//                               _formKey.currentState.save();
//                               Navigator.pop(context);
//                             }
//                           })
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           );
//         },
//       );

//   void deleteBed(int i) {
//     setState(() {
//       bedNames.removeAt(i);
//       bedIds.removeAt(i);
//       activeList.removeAt(i);
//     });
//   }

//   void addBed() {
//     counter++;
//     setState(() {
//       bedNames.add('New Bed $counter');
//       bedIds.add('');
//       activeList.add(true);
//     });
//   }

//   Widget buildBed(int index, QueryDocumentSnapshot<Object> bed) {
//     return Card(
//         margin: EdgeInsets.only(top: 6, bottom: 6),
//         key: ValueKey(index),
//         child: ListTile(
//           // key: ValueKey(bed['name']),
//           tileColor: Colors.white,
//           // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           title: Text(bedNames[index]),
//           subtitle: Text(bed['occupied'] ? '${bed['ptDetails']}' : '-'),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.black),
//                 onPressed: () {
//                   print('edir pressed');
//                   edit(index);
//                 },
//               ),
//               activeList[index]
//                   ? IconButton(
//                       icon: Icon(Icons.wb_sunny_outlined, color: Colors.black),
//                       onPressed: () => setState(() =>
//                           bed['occupied'] ? null : activeList[index] = false),
//                     )
//                   : IconButton(
//                       icon: Icon(Icons.nightlight_round_outlined,
//                           color: Colors.black),
//                       onPressed: () => setState(() => activeList[index] = true),
//                     ),
//             ],
//           ),
//         ));
//   }

//   Widget buildNewBed(int index) {
//     return Card(
//       margin: EdgeInsets.only(top: 6, bottom: 6),
//       key: ValueKey(index),
//       child: ListTile(
//         tileColor: Colors.white,
//         // contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//         title: Text(bedNames[index]),
//         subtitle: Text('-'),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: Icon(Icons.edit, color: Colors.black),
//               onPressed: () => edit(index),
//             ),
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.black),
//               onPressed: () => deleteBed(index),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<QuerySnapshot<Object>>(
//       future: future,
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Ward (${ward['name']})'),
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ElevatedButton(
//                     child: Text('Update'),
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.white, // background
//                       onPrimary: Colors.black, // foreground
//                     ),
//                     onPressed: () => updateWardBed(),
//                   ),
//                 )
//               ],
//             ),
//             backgroundColor: Theme.of(context).primaryColor,
//             body: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: ListView(
//                 shrinkWrap: true,
//                 padding: EdgeInsets.all(8),
//                 children: [
//                   Center(
//                     child: ElevatedButton(
//                       child: Icon(Icons.add),
//                       style: ElevatedButton.styleFrom(
//                           primary: Colors.white,
//                           onPrimary: Colors.black,
//                           fixedSize: Size(50, 20)),
//                       onPressed: () => addBed(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   ReorderableListView.builder(
//                     physics: const ScrollPhysics(),
//                     shrinkWrap: true,
//                     // padding: const EdgeInsets.symmetric(horizontal: 10),
//                     itemCount: bedIds.length,
//                     itemBuilder: (context, index) {
//                       var wBed = bedDocs?.firstWhere(
//                           (bed) => bed.id == bedIds[index],
//                           orElse: () => null);
//                       Widget bedTile = wBed == null
//                           ? buildNewBed(index)
//                           : buildBed(index, wBed);
//                       return bedTile;
//                     },
//                     onReorder: (int oldIndex, int newIndex) {
//                       setState(() {
//                         var index =
//                             newIndex > oldIndex ? newIndex - 1 : newIndex;
//                         String bId = bedIds.removeAt(oldIndex);
//                         bedIds.insert(index, bId);
//                         String bName = bedNames.removeAt(oldIndex);
//                         bedNames.insert(index, bName);
//                         bool bBool = activeList.removeAt(oldIndex);
//                         activeList.insert(index, bBool);
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }
