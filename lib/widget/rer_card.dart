import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:intl/intl.dart';
import 'package:substring_highlight/substring_highlight.dart';
// import 'package:selectable_autolink_text/selectable_autolink_text.dart';

class RerCard extends StatelessWidget {
  final int entryTime;
  final String dept;
  final String byId;
  final String data;
  final TextEditingController tec;
  final int index;
  final String uid;
  final TabController tc;
  final TextStyle linkStyle = TextStyle(
    color: Colors.blue,
  );

  RerCard(this.entryTime, this.dept, this.byId, this.data, this.tec, this.index,
      this.uid, this.tc);

  // List<bool> _isOpen = [false];

//   @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
        margin: const EdgeInsets.all(3),
        // try tomorrow when come back, column in column... for name and time. YEAH!!
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(deptListController.deptSName(dept),
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  (DateTime.fromMillisecondsSinceEpoch(entryTime)
                                  .difference(DateTime.now())
                                  .inHours <
                              12) &&
                          (byId == uid)
                      ? Container()
                      : RichText(
                          text: TextSpan(
                              text: 'Edit Entry',
                              style: linkStyle,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ecController.mainEditor.text = data;
                                  ecController.editId.value =
                                      entryTime.toString();
                                  ecController.deptId.value = dept;
                                  tc.animateTo(3);
                                }),
                        )
                ],
              ),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(userListController.userSName(byId),
                      style: TextStyle(fontWeight: FontWeight.w400)),
                  Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon(Icons.start),
                          Text('Start'),
                          SizedBox(
                            height: 25,
                            width: 50,
                            child: Switch(
                              // materialTapTargetSize:
                              //     MaterialTapTargetSize.shrinkWrap,
                              value: index == ecController.start.value,
                              onChanged: (value) {
                                if (value) {
                                  ecController.makeStart(index);
                                } else {
                                  ecController.removeStart();
                                }
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                            ),
                          )
                        ],
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      DateFormat('dd/MM/yyyy kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(entryTime)),
                      style: TextStyle(fontWeight: FontWeight.w400)),
                  Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon(Icons.stop),
                          Text('Stop'),
                          SizedBox(
                            height: 25,
                            width: 50,
                            child: Switch(
                              // materialTapTargetSize:
                              //     MaterialTapTargetSize.shrinkWrap,
                              value: index == ecController.end.value,
                              onChanged: (value) {
                                if (value) {
                                  ecController.makeEnd(index);
                                } else {
                                  ecController.removeEnd();
                                }
                              },
                              activeTrackColor: Colors.redAccent,
                              activeColor: Colors.red,
                            ),
                          )
                        ],
                      )),
                ],
              ),
              // ExpansionPanelList(
              //   animationDuration: const Duration(seconds: 1),
              //   expansionCallback: (i, isOpen) => setState(() {
              //     _isOpen[i] = !isOpen;
              //   }),
              //   children: [
              //     ExpansionPanel(
              //       isExpanded: _isOpen[0],
              //         headerBuilder: (BuildContext context, bool isExpanded) {
              //           return Text('');
              //         },
              //         body: Obx(() => Column(
              //               children: [
              //                 Row(
              //                   children: [
              //                     Text('Start'),
              //                     Switch(
              //                       value: index ==
              //                           ecController.start.value,
              //                       onChanged: (value) {
              //                         if (value) {
              //                           ecController.makeStart(index);
              //                         } else {
              //                           ecController.removeStart();
              //                         }
              //                       },
              //                       activeTrackColor: Colors.lightGreenAccent,
              //                       activeColor: Colors.green,
              //                     )
              //                   ],
              //                 ),
              //                 Row(
              //                   children: [
              //                     Text('End'),
              //                     Switch(
              //                       value: index ==
              //                           ecController.start.value,
              //                       onChanged: (value) {
              //                         if (value) {
              //                           ecController.makeEnd(index);
              //                         } else {
              //                           ecController.removeEnd();
              //                         }
              //                       },
              //                       activeTrackColor: Colors.redAccent,
              //                       activeColor: Colors.red,
              //                     )
              //                   ],
              //                 ),
              //                 uid == byId
              //                     ? ElevatedButton(
              //                         child: Text('Edit'),
              //                         onPressed: () {
              //                           // jump to edit with edit and cancel
              //                           ecController.editId.value =
              //                               entryTime.toString();
              //                           ecController.deptId.value = dept;
              //                           ecController.mainEditor.text =
              //                               data;
              //                           tc.animateTo(2);
              //                         },
              //                       )
              //                     : Container()
              //               ],
              //             ))),
              //   ],
              // ),
              // SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: ecController.deptId.value.isEmpty
                        ?
                        // data.split('\n').map((String data) {
                        //     return SelectableText(
                        //       data,
                        //       style: TextStyle(
                        //           fontWeight:
                        //               ecController.searchString.isNotEmpty &&
                        //                       data.contains(
                        //                           ecController.searchString)
                        //                   ? FontWeight.bold
                        //                   : null),
                        //     );
                        //   }).toList()
                        tec.text.isNotEmpty
                            ? [
                                SubstringHighlight(
                                  text: data,
                                  term: tec.text,
                                )
                              ]
                            : [
                                SelectableText(
                                  data,
                                  autofocus: false,
                                  dragStartBehavior: DragStartBehavior.start,
                                  enableInteractiveSelection: true,
                                )
                                // SelectableAutoLinkText(
                                //   data,
                                //   linkStyle:
                                //       TextStyle(color: Colors.blueAccent),
                                //   highlightedLinkStyle: TextStyle(
                                //     color: Colors.redAccent,
                                //     backgroundColor:
                                //         Colors.blueAccent.withAlpha(0x33),
                                //   ),
                                //   // onTap: (url) => launch(url, forceSafariVC: false),
                                //   // onLongPress: (url) => Share.share(url),
                                // )
                              ]
                        : data.split('\n').map((String data) {
                            return Container(
                              decoration: BoxDecoration(
                                // color: Colors.lightBlue,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(2.0),
                              child: ListTile(
                                // ListTile has its own inkwell effect
                                onTap: () =>
                                    ecController.insertText(data + ' \n'),
                                visualDensity:
                                    VisualDensity(horizontal: 0, vertical: -4),
                                dense: true,
                                title: Text(
                                  data,
                                  style: TextStyle(
                                      fontWeight: ecController
                                                  .searchString.isNotEmpty &&
                                              data.contains(
                                                  ecController.searchString)
                                          ? FontWeight.bold
                                          : null),
                                ),
                                tileColor: ecController
                                            .searchString.isNotEmpty &&
                                        data.contains(ecController.searchString)
                                    ? Colors.red
                                    : null
                                // Colors.lightBlueAccent
                                ,
                              ),
                              // )
                            );
                            // ListTile(
                            //   visualDensity:
                            //       VisualDensity(horizontal: 0, vertical: -4),
                            //   dense: true,
                            //   title: Text(
                            //     data,
                            //     style: TextStyle(
                            //         fontWeight:
                            //             ecController.searchString.isNotEmpty &&
                            //                     data.contains(
                            //                         ecController.searchString)
                            //                 ? FontWeight.bold
                            //                 : null),
                            //   ),
                            //   tileColor: ecController.searchString.isNotEmpty &&
                            //           data.contains(ecController.searchString)
                            //       ? Colors.blue
                            //       : null,
                            //   onTap: () =>
                            //       ecController.insertText(data + ' \n'),
                            // );
                          }).toList()),
              ),
            ],
          ),
        )));
  }
}
