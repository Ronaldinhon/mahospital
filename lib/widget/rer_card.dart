import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:intl/intl.dart';

class RerCard extends StatelessWidget {
  final int entryTime;
  final String dept;
  final String byId;
  final String data;

  RerCard(this.entryTime, this.dept, this.byId, this.data);

//   @override
//   _RerCardState createState() => _RerCardState();
// }

// class _RerCardState extends State<RerCard> {
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
              Text(deptListController.deptSName(dept),
                  style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text(userListController.userSName(byId),
                  style: TextStyle(fontWeight: FontWeight.w400)),
              Text(
                  DateFormat('dd/MM/yyyy kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(entryTime)),
                  style: TextStyle(fontWeight: FontWeight.w400)),
              SizedBox(height: 3),
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
                        [
                            SelectableText(
                              data,
                              // style: TextStyle(
                              //     fontWeight:
                              //         ecController.searchString.isNotEmpty &&
                              //                 data.contains(
                              //                     ecController.searchString)
                              //             ? FontWeight.bold
                              //             : null),
                            )
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
                              child:
                                  // InkWell(
                                  //   onTap: () =>
                                  //       ecController.insertText(data + ' \n'),
                                  //   child:
                                  ListTile(
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
