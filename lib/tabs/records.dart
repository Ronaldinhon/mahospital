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

  Records(this.tc, this.isc, this.ipc);
  @override
  _RecordsState createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  // TextEditingController in controller
  late String uid;
  late DocumentReference rer;
  late List<int> orderedDateTime;
  List<Widget> entryCards = [];

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

  final List<String> deptShortcut = [
    'Gen',
    'Med',
    'Surg',
    'O+G',
    'Peads',
    'Ortho',
  ];

  @override
  void initState() {
    uid = auth.currentUser!.uid;
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
        entryCards.add(RerCard(odt, rerM['dept'].toString(),
            rerM['byId'].toString(), rerM['data'].toString()));
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
              child: Column(
            children: [
              // ElevatedButton(
              //   child: Text('Jump Tab'),
              //   onPressed: () => widget.tc.animateTo(2),
              // ),
              Row(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(6.0),
                  //   child: IconButton(
                  //     icon: Icon(
                  //       Icons.add,
                  //       color: Colors.red,
                  //     ),
                  //     onPressed: () {
                  //       ecController.editingEntry.value = true;
                  //       setState(() {});
                  //       fc1.requestFocus();
                  //     },
                  //   ),
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: ecController.searchCont,
                            autocorrect: false,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              labelText: 'Keyword',
                              suffixIcon: IconButton(
                                focusNode: ecController.fc,
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  ecController
                                      .searchData(ecController.searchCont.text);
                                  ecController.fc.unfocus();
                                  ecController.isSelected.value = [
                                    false,
                                    false,
                                    false,
                                    false,
                                    false,
                                    false,
                                  ];
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ToggleButtons(
                              children: deptShortcut
                                  .map((String ss) => Text(ss))
                                  .toList(),
                              onPressed: (int index) {
                                for (int buttonIndex = 0;
                                    buttonIndex <
                                        ecController.isSelected.length;
                                    buttonIndex++) {
                                  if (buttonIndex == index) {
                                    ecController.isSelected[buttonIndex] = true;
                                  } else {
                                    ecController.isSelected[buttonIndex] =
                                        false;
                                  }
                                }
                                ecController.searchDept(deptShortcut[index]);
                              },
                              isSelected: ecController.isSelected,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_upward),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_downward),
                          onPressed: () {},
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          )),
          Obx(() => Expanded(
                flex: 1,
                child:
                    // Container(color: Colors.black,)
                    ScrollablePositionedList.builder(
                  padding: EdgeInsets.all(18.0),
                  scrollDirection: Axis.vertical,
                  itemCount: currentWPLC.cwpm.value.rerIni
                      ? currentWPLC.cwpm.value.entries.length
                      : 0,
                  // entryCards.length,
                  itemBuilder: (context, index) {
                    List odt = currentWPLC.cwpm.value.orderedDateTime;
                    var ent =
                        currentWPLC.cwpm.value.entries[odt[index].toString()];
                    print(ent);
                    ecController.entryData.add(ent['data'].toString());
                    ecController.depts.add(ent['dept'].toString());
                    return RerCard(odt[index], ent['dept'].toString(),
                        ent['byId'].toString(), ent['data'].toString());
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
