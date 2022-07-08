import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:mahospital/models/bed_model.dart';

class AsBedScreen extends StatefulWidget {
  final WardModel wm;

  AsBedScreen(this.wm);
  @override
  _AsBedScreenState createState() => _AsBedScreenState();
}

class _AsBedScreenState extends State<AsBedScreen> {
  // bool _bedIsLoading = false;
  final _formKey = GlobalKey<FormState>();
  late String uid;
  late String errorMessage;

  late WardModel ward;

  List<String> bedIds = [];
  List<String> bedNames = [];
  List<bool> o2 = [];
  List<bool> activeList = [];
  late List<BedModel> bms;
  int counter = 0;
  bool initialised = false;

  List<String> errorList = [];

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    ward = widget.wm;
    // awaitLocalBeds(); initialise list??
    super.initState();
  }

  Future<List> iniBedList() async {
    // bms = await ward.getBeds();
    if (!initialised) {
      bms = ward.bedModels;
      bms.forEach((bm) {
        bedIds.add(bm.id);
        bedNames.add(bm.name);
        o2.add(bm.o2);
        activeList.add(bm.active);
      });
      initialised = true;
    }

    return bedIds;
  }

  void updateWardBed() {
    _onLoading();
    if (bedIds.isNotEmpty)
      createBed(0);
    else
      _onLoadingDone();
    // bedIds.asMap().forEach((index, bedId) {
    //   if (bedId.isEmpty) {
    //     createBed(index);
    //   } else {
    //     updateBed(index);
    //   }
    // });

    // bedIds.removeWhere((value) => value == '');
    // wardRef.doc(widget.wardId).update({'bedIdList': bedIds});
    // if (errorList.isNotEmpty) {
    //   message = Text('Error occured when updating bed ${errorList.join(', ')}');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: message,
    //       backgroundColor: Theme.of(context).errorColor,
    //     ),
    //   );
    // } else
    //   Navigator.pop(context);
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                new Text("Loading"),
              ],
            ),
          ),
        );
      },
    );
    // new Future.delayed(new Duration(seconds: 3), () {
    //   Navigator.pop(context); //pop dialog
    //   _login();
    // });
  }

  void _onLoadingDone() {
    Navigator.pop(context);
    Text message = Text('All beds have been updated');
    bedIds.removeWhere((value) => value == '');
    print(bedIds);
    wardRef.doc(ward.id).update({'bedIdList': bedIds}); // i think must limit only ward owner can change beds
    if (errorList.isNotEmpty) {
      message = Text('Error occured when updating bed ${errorList.join(', ')}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: message,
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } else
      Navigator.pop(context);
  }

  void createBed(int index) async {
    String lbi = bedIds[index];
    print(lbi);
    try {
      if (lbi.isEmpty)
        await bedRef.add({
          'name': bedNames[index],
          'o2': o2[index],
          'wardId': ward.id,
          'deptId': ward.deptId,
          'hospId': ward.hospId,
          'occupied': false,
          'ptId': null,
          // 'ptDetails': null, //do we need this?
          'active': true,
          'lastUpdatedBy': uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }).then((DocumentReference<Object?> v) {
          bedIds[index] = v.id;
          if (index == bedIds.length - 1)
            _onLoadingDone();
          else
            createBed(++index);
        });
      else
        await bedRef.doc(bedIds[index]).update({
          'active': activeList[index],
          'name': bedNames[index],
          'o2': o2[index],
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }).then((v) {
          if (index == bedIds.length - 1)
            _onLoadingDone();
          else
            createBed(++index);
        });
    } catch (error) {
      errorList.add(bedNames[index]);
      if (index == bedIds.length - 1)
        _onLoadingDone();
      else
        createBed(++index);
    }
  }

  // void updateBed(int index) async {
  //   // need to check first
  //   try {
  //     await bedRef.doc(bedIds[index]).update(
  //         {'active': activeList[index], 'name': bedNames[index]}).then((v) {
  //       if (index == bedIds.length - 1)
  //         _onLoadingDone();
  //       else
  //         createBed(index++);
  //     });
  //   } catch (error) {
  //     errorList.add(bedNames[index]);
  //   }
  //   if (index == bedIds.length - 1) _onLoadingDone();
  // }

  void edit(int index) async {
    Map edited = await Get.defaultDialog(
      contentPadding: EdgeInsets.all(15.0),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                validator: (val) {
                  if (val!.trim().isEmpty) {
                    return 'Bed name is required!';
                  }
                  return null;
                },
                // RequiredValidator(errorText: 'Bed name is required'),
                initialValue: bedNames[index],
                onSaved: (name) {
                  setState(() => bedNames[index] = name!.trim());
                },
                // onFieldSubmitted: (_) => Navigator.of(context).pop(),
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(
                //       new RegExp(r"/^(\w+\s?)$/"))
                // ],
              ),
              SwitchListTile(
                  title: Text(
                    'O2 Port',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  value: o2[index],
                  activeColor: Colors.blue,
                  inactiveTrackColor: Colors.grey,
                  onChanged: (bool value) {
                    setState(() => o2[index] = value);
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      child: Text('Save'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Get.back(result: {
                            'name': bedNames[index],
                            'o2': o2[index]
                          });
                        }
                      })
                ],
              )
            ],
          ),
        );
      }),
    );
    setState(() {
      bedNames[index] = edited['name'];
      o2[index] = edited['o2'];
    });
  }

  void deleteBed(int i) {
    setState(() {
      bedNames.removeAt(i);
      bedIds.removeAt(i);
      o2.removeAt(i);
      activeList.removeAt(i);
    });
  }

  void addBed() {
    counter++;
    setState(() {
      bedNames.add('New Bed $counter');
      bedIds.add('');
      o2.add(false);
      activeList.add(true);
    });
  }

  Widget buildBed(int index, BedModel bed) {
    print(bed.ptId.isNotEmpty);
    return Card(
        margin: EdgeInsets.only(top: 6, bottom: 6),
        key: ValueKey(index),
        child: ListTile(
          // key: ValueKey(bed['name']),
          tileColor: Colors.white,
          // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          title: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              bedNames[index],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'O2 Port: ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      o2[index]
                          ? WidgetSpan(
                              child: Icon(
                                Icons.check_box,
                                color: Colors.blue,
                                size: 18,
                              ),
                            )
                          : WidgetSpan(
                              // text:
                              //     String.fromCharCode(0xe157), //<-- charCode
                              child: Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.blue,
                                size: 18,
                              ),
                            )
                    ],
                  ),
                ),
                Text(
                  'Pt: ' +
                      (bed.ptId.isNotEmpty ? bed.wardPtModel.ptDetails() : '-'),
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    edit(index);
                  },
                ),
                activeList[index]
                    ? IconButton(
                        icon:
                            Icon(Icons.wb_sunny_outlined, color: Colors.black),
                        onPressed: () => setState(() => bed.ptId.isNotEmpty
                            ? null
                            : activeList[index] = false),
                      )
                    : IconButton(
                        icon: Icon(Icons.nightlight_round_outlined,
                            color: Colors.black),
                        onPressed: () =>
                            setState(() => activeList[index] = true),
                      ),
              ],
            ),
          ),
        ));
  }

  Widget buildNewBed(int index) {
    return Card(
      margin: EdgeInsets.only(top: 6, bottom: 6),
      key: ValueKey(index),
      child: ListTile(
        tileColor: Colors.white,
        // contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        title: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            bedNames[index],
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                textAlign: TextAlign.end,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'O2 Port: ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    o2[index]
                        ? WidgetSpan(
                            child: Icon(
                              Icons.check_box,
                              color: Colors.blue,
                              size: 18,
                            ),
                          )
                        : WidgetSpan(
                            // text:
                            //     String.fromCharCode(0xe157), //<-- charCode
                            child: Icon(
                              Icons.check_box_outline_blank,
                              color: Colors.blue,
                              size: 18,
                            ),
                          )
                  ],
                ),
              ),
              Text(
                'Pt: -',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.black),
                onPressed: () => edit(index),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: () => deleteBed(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: iniBedList(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Ward (${ward.name})'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white, // background
                      onPrimary: Colors.black, // foreground
                    ),
                    onPressed: () => updateWardBed(),
                  ),
                )
              ],
            ),
            backgroundColor: Theme.of(context).primaryColor,
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                children: [
                  Center(
                    child: ElevatedButton(
                      child: Icon(Icons.add),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.black,
                          fixedSize: Size(50, 20)),
                      onPressed: () => addBed(),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 550),
                      child: ReorderableListView.builder(
                        // buildDefaultDragHandles: false,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        // padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: bedIds.length,
                        itemBuilder: (context, index) {
                          // var wBed = bedDocs?.firstWhere(
                          //     (bed) => bed.id == bedIds[index],
                          //     orElse: () => null);
                          Widget bedTile = bedIds[index].isEmpty
                              ? buildNewBed(index)
                              : buildBed(
                                  index,
                                  bms.firstWhere(
                                      (bm) => bm.id == bedIds[index]));
                          return bedTile;
                        },
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            var index =
                                newIndex > oldIndex ? newIndex - 1 : newIndex;
                            String bId = bedIds.removeAt(oldIndex);
                            bedIds.insert(index, bId);
                            String bName = bedNames.removeAt(oldIndex);
                            bedNames.insert(index, bName);
                            bool oBool = o2.removeAt(oldIndex);
                            o2.insert(index, oBool);
                            bool bBool = activeList.removeAt(oldIndex);
                            activeList.insert(index, bBool);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// final String wardId;
// final List<BedModel> localBedModels;
// Future<QuerySnapshot<Object>> future;
// QuerySnapshot<Object> localBeds;
// List<QueryDocumentSnapshot<Object>> bedDocs;
// void awaitLocalBeds() async {
//   localBeds = await future;
//   bedDocs = localBeds.docs;
//   if (bedIds != null)
//     bedIds.asMap().forEach((index, bed) {
//       var wBed = bedDocs?.firstWhere((bed) => bed.id == bedIds[index],
//           orElse: () => null);
//       bedNames.add(wBed['name']);
//       activeList.add(wBed['active']);
//     });
// }

// future = getDeptAndBed();
// Future<QuerySnapshot<Object>> getDeptAndBed() async {
//   Future<QuerySnapshot<Object>> st =
//       wardRef.doc(widget.wardId).get().then((qward) {
//     ward = qward;
//     bedIds = ward['bedIdList'];
//     return bedRef.where('wardId', isEqualTo: qward.id).get();
//   });
//   return st;
// }
