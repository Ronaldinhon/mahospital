import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/widget/rer_card.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Records extends StatefulWidget {
  final TabController tc;
  final ItemScrollController isc;
  final ItemPositionsListener ipc;
  final FocusNode fc;
  final TextEditingController searchCont;
  final List<bool> isSel;

  Records(this.tc, this.isc, this.ipc, this.fc, this.searchCont, this.isSel);
  @override
  _RecordsState createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  // TextEditingController in controller
  late String uid;
  late DocumentReference rer;
  late List<int> orderedDateTime;
  List<Widget> entryCards = [];
  final _formKey = GlobalKey<FormState>();

  // bool loading = false;
  // String searchField = '';
  final FocusNode fc1 = FocusNode();

  final Map cardExample = {
    'dept': 'Med',
    'byId': 'stan',
    'createdAt': 1640364996429,
    'data': [
      'data',
      'data',
      'data',
      'data',
    ]
  };

  // final List<String> deptShortcut = [
  //   'Gen',
  //   'Med',
  //   'Surg',
  //   'O+G',
  //   'Peads',
  //   'Ortho',
  // ];

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    widget.ipc.itemPositions.addListener(() {
      // if (widget.ipc.itemPositions.value.first.index >=
      //     currentWPLC.cwpm.value.entries.length - 6) {
      //   currentWPLC.cwpm.value.addFakeEntry();
      //   setState(() {});
      // }
      // print(currentWPLC.cwpm.value.entries.length.toString() +
      //     ' - current displayed length');
      // print(widget.ipc.itemPositions.value.first.index);
      // print(currentWPLC.cwpm.value.entries.values.last);
    });
    // getRer(currentWPLC.cwpm.value.id);
    // rers = getRer(currentWPLC.cwpm.value.id);

    // if (ecController.itemScrollController.isAttached) {
    //   ecController.itemScrollController.scrollTo(
    //       index: 0,
    //       duration: Duration(seconds: 1),
    //       curve: Curves.easeInOutCubic);
    // }

    // entryCards.add(RerCard(cardExample['createdAt'], cardExample['dept'],
    //     cardExample['byId'], cardExample['data']));
    // entryCards.add(RerCard(cardExample['createdAt'], cardExample['dept'],
    //     cardExample['byId'], cardExample['data']));
    // entryCards.add(RerCard(cardExample['createdAt'], cardExample['dept'],
    //     cardExample['byId'], cardExample['data']));
    // entryCards.add(RerCard(cardExample['createdAt'], cardExample['dept'],
    //     cardExample['byId'], cardExample['data']));

    super.initState();
  }

  // Future<List> rers = getRer(currentWPLC.cwpm.value.id);
  Future<List> getRer(String id) async {
    // rer = wardPtRef.doc(id).collection('entries').doc('1');
    // DocumentSnapshot rerSS = await rer.get();
    // if (rerSS.exists) {
    if (currentWPLC.cwpm.value.rerIni) {
      entryCards = [];
      // Map rerMap = rerSS.get('entries');
      Map rerMap = currentWPLC.cwpm.value.entries;
      orderedDateTime = rerMap.keys.map((f) => int.parse(f)).toList();
      orderedDateTime.sort((a, b) => b.compareTo(a)); // reversed
      for (var odt in orderedDateTime) {
        Map<String, dynamic> rerM = rerMap[odt.toString()];
        // entryCards.add(RerCard(
        //     odt,
        //     rerM['dept'].toString(),
        //     rerM['byId'].toString(),
        //     rerM['data'].toString(),
        //     widget.searchCont));
        ecController.entryData.add(rerM['data'].toString());
        ecController.depts.add(rerM['dept'].toString());
        // print('entryCards.length');
        await userListController.createAndSave(rerM['byId'].toString());
        // how to get all user data?
      }
      return entryCards;
    } else {
      return entryCards;
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // Obx(() =>
        // FutureBuilder<List>(
        //       future: getRer(currentWPLC.cwpm.value.id),
        //       builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        //         if (snapshot.connectionState == ConnectionState.done) {
        //           return
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child:
                //   // ElevatedButton(
                //   //   child: Text('Jump Tab'),
                //   //   onPressed: () => widget.tc.animateTo(2),
                //   // ),
                Padding(
              padding: const EdgeInsets.only(
                  top: 0, left: 8.0, right: 8.0, bottom: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextField(
                          controller: ecController.searchCont,
                          autocorrect: false,
                          // keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: 'Keyword',
                            suffixIcon: IconButton(
                              focusNode: widget.fc,
                              icon: Icon(Icons.search),
                              onPressed: () {
                                ecController.searchData(widget.searchCont.text,
                                    widget.isc, widget.ipc, widget.isSel);
                                widget.fc.unfocus();
                                // ecController.falsifyIS();
                              },
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_upward),
                        onPressed: () =>
                            ecController.upSearch(widget.isc, widget.ipc),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward),
                        onPressed: () =>
                            ecController.downSearch(widget.isc, widget.ipc),
                      )
                    ],
                  ),
                  // SizedBox(
                  //   height: 4,
                  // ),
                  Row(
                    // mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Obx(() => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ToggleButtons(
                                children: currentWPLC.cwpm.value.uniqueDept
                                    .map((String ss) =>
                                        Text(deptListController.deptSName(ss)))
                                    .toList(),
                                onPressed: (int index) {
                                  for (int buttonIndex = 0;
                                      buttonIndex <
                                          currentWPLC.cwpm.value.isSel.length;
                                      buttonIndex++) {
                                    if (buttonIndex == index) {
                                      currentWPLC
                                          .cwpm.value.isSel[buttonIndex] = true;
                                    } else {
                                      currentWPLC.cwpm.value
                                          .isSel[buttonIndex] = false;
                                    }
                                  }
                                  ecController.searchDept(
                                      currentWPLC.cwpm.value.uniqueDept[index],
                                      widget.isc,
                                      widget.ipc);
                                  setState(() {});
                                },
                                isSelected: currentWPLC.cwpm.value.isSel,
                              ),
                            )),
                      ),
                      Flexible(
                          flex: 2,
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 3.0,
                                right: 3.0,
                              ),
                              child: TextFormField(
                                controller: ecController.pgCodeCont,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  labelText: 'Code//Pg',
                                  suffixIcon: IconButton(
                                      focusNode: widget.fc,
                                      icon: Icon(Icons.print),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          ecController.printingRec.value = true;
                                        }
                                      }),
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return 'Code is required!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          )),
                    ],
                  ),
                  // SizedBox(
                  //   height: 3,
                  // ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       IconButton(
            //         icon: Icon(Icons.print),
            //         onPressed: () =>
            //             ecController.printingRec.value = true,
            //       )
            //     ],
            //   ),
            // )
          ),
          Obx(() => Expanded(
                flex: 1,
                child:
                    // Container(color: Colors.black,)
                    ScrollablePositionedList.builder(
                  padding: EdgeInsets.all(12.0),
                  scrollDirection: Axis.vertical,
                  itemCount: currentWPLC.cwpm.value.rerIni
                      ? currentWPLC.cwpm.value.entries.length + 1
                      : 0,
                  // entryCards.length,
                  itemBuilder: (context, index) {
                    List odt = currentWPLC.cwpm.value.orderedDateTime;
                    var ent = index != currentWPLC.cwpm.value.entries.length
                        ? currentWPLC.cwpm.value.entries[odt[index].toString()]
                        : null;
                    if (index != currentWPLC.cwpm.value.entries.length) {
                      // print(ent['data']);
                      if (index == 0) ecController.entryData = [];
                      if (index == 0) ecController.deptList = [];
                      ecController.entryData.add(ent['data']
                          .toString()); // these 2 lines for search purpose
                      ecController.deptList.add(ent['dept'].toString());
                      if (index == currentWPLC.cwpm.value.entries.length - 1)
                        ecController.setupDepts();
                    }
                    return index != currentWPLC.cwpm.value.entries.length
                        ? RerCard(
                            odt[index],
                            ent['dept'].toString(),
                            ent['byId'].toString(),
                            ent['data'].toString(),
                            widget.searchCont,
                            currentWPLC.cwpm.value.entries.length - 1 - index,
                            uid,
                            widget.tc)
                        : ElevatedButton(
                            child: Text('load'),
                            onPressed: () {
                              currentWPLC.cwpm.value.addFakeEntry();
                              setState(() {});
                              // widget.isc.scrollTo(
                              //     index: currentWPLC.cwpm.value.entries.length,
                              //     duration: Duration(seconds: 0));
                            },
                          );
                  },
                  // entryCards[index],
                  itemScrollController: widget.isc,
                  itemPositionsListener: widget.ipc,
                ),
              )),
        ],
      );
    })
        // ;
        //     } else {
        //       return CircularProgressIndicator();
        //     }
        //   },
        // )
        // )
        ;
  }
}
