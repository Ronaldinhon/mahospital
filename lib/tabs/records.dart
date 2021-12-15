import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/widget/rer_card.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Records extends StatefulWidget {
  @override
  _RecordsState createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  // TextEditingController in controller
  late String uid;
  late DocumentReference rer;
  late List<int> orderedDateTime;
  List<Widget> entryCards = [];

  bool loading = false;
  // String searchField = '';
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<String> depts = [];
  List<List<String>> entryData = [];
  List<int> searchedIndexes = [];
  // final _formKey = GlobalKey<FormState>();
  final FocusNode fc = FocusNode();
  final FocusNode fc1 = FocusNode();
  final searchCont = TextEditingController();

  List<bool> isSelected = [
    true,
    false,
    false,
    false,
    false,
    false,
  ];
  final List<String> deptShortcut = [
    'None',
    'Med',
    'Surg',
    'O+G',
    'Peads',
    'Ortho',
  ];

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    super.initState();
  }

  Future<List> getRer(String id) async {
    rer = wardPtRef.doc(id).collection('rer').doc('1');
    DocumentSnapshot rerSS = await rer.get();
    if (rerSS.exists) {
      Map rerMap = rerSS.get('rers');
      orderedDateTime = rerMap.keys.toList() as List<int>;
      orderedDateTime.sort((a, b) => b.compareTo(a)); // reversed
      for (var odt in orderedDateTime) {
        Map<String, dynamic> rerM = rerMap[odt];
        entryCards.add(RerCard(odt, rerM['dept'], rerM['byId'], rerM['data']));
        entryData.add(rerM['data']);
        depts.add(rerM['dept']);
        // rerM['byId'];
        // rerM['updatedAt'];
        // rerM['createdAt'];
      }
      return entryCards;
    } else {
      return entryCards;
    }
  }

  void _searchData(String keyWord) {
    searchedIndexes = [];
    entryData.asMap().forEach((i, element) {
      for (var i = 0; i < element.length; i++) {
        if (element[i].contains(keyWord)) {
          searchedIndexes.add(i);
          break;
        }
      }
    });
    itemScrollController.scrollTo(
        index: searchedIndexes[0], duration: Duration(milliseconds: 200));
  }

  void _searchDept(String dept) {
    searchedIndexes = [];
    for (var i = 0; i < depts.length; i++) {
      if (depts[i] == dept) {
        searchedIndexes.add(i);
      }
    }
    itemScrollController.scrollTo(
        index: searchedIndexes[0], duration: Duration(milliseconds: 200));
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

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureBuilder<List>(
          future: getRer(currentWPLC.cwpm.value.id),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                        child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ecController.editingEntry.value = true;
                                  setState(() {});
                                  fc1.requestFocus();
                                },
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: searchCont,
                                    decoration: InputDecoration(
                                      labelText: 'Keyword',
                                      suffixIcon: IconButton(
                                        focusNode: fc,
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          _searchData(searchCont.text);
                                          fc.unfocus();
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
                                        setState(() {
                                          for (int buttonIndex = 0;
                                              buttonIndex < isSelected.length;
                                              buttonIndex++) {
                                            if (buttonIndex == index) {
                                              isSelected[buttonIndex] = true;
                                            } else {
                                              isSelected[buttonIndex] = false;
                                            }
                                          }
                                        });
                                        _searchDept(deptShortcut[index]);
                                      },
                                      isSelected: isSelected,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                            Column(
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
                            )
                          ],
                        ),
                        !ecController.editingEntry.value
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ConstrainedBox(
                                      constraints: new BoxConstraints(
                                        maxHeight: 120.0,
                                      ),
                                      child: SingleChildScrollView(
                                        reverse: true,
                                        child: TextFormField(
                                          focusNode: fc1,
                                          key: ValueKey('entry'),
                                          decoration: InputDecoration(
                                            labelText: 'Entry',
                                          ),
                                          // initialValue: dx,
                                          keyboardType: TextInputType.multiline,
                                          controller: ecController.mainEditor,
                                          maxLines: null,
                                          // onSaved: (value) {
                                          //   dx = value!.trim();
                                          // },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children:
                                            demoSC.keys.map((String head) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: OutlinedButton(
                                              child: Text(head),
                                              onPressed: () =>
                                                  ecController.insertText(
                                                      demoSC[head]! + ' \n'),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: pwSC.keys.map((String head) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: OutlinedButton(
                                              child: Text(head),
                                              onPressed: () =>
                                                  ecController.insertText(
                                                      pwSC[head]! + ' \n'),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: dxSC.keys.map((String head) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: OutlinedButton(
                                              child: Text(head),
                                              onPressed: () =>
                                                  ecController.insertText(
                                                      dxSC[head]! + ' \n'),
                                            ),
                                          );
                                        }).toList(),
                                      ),
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
                                              onPressed: () =>
                                                  ecController.insertText(
                                                      curSC[head]! + ' \n'),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: oeSC.keys.map((String head) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: OutlinedButton(
                                              child: Text(head),
                                              onPressed: () =>
                                                  ecController.insertText(
                                                      oeSC[head]! + ' \n'),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ) // find in mobs
                      ],
                    )),
                    Expanded(
                      child: ScrollablePositionedList.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: entryCards.length,
                        itemBuilder: (context, index) => entryCards[index],
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                      ),
                    ),
                  ],
                );
              });
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}
