import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';

class RerCard extends StatelessWidget {
  final int entryTime;
  final String dept;
  final String byId;
  final List<String> data;

  RerCard(this.entryTime, this.dept, this.byId, this.data);

//   @override
//   _RerCardState createState() => _RerCardState();
// }

// class _RerCardState extends State<RerCard> {
//   @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
        margin: const EdgeInsets.all(3),
        child: Column(
            children: ecController.editingEntry.value
                ? data.map((String data) {
                    return Text(
                      data,
                      style: TextStyle(
                          fontWeight: ecController.searchString.isNotEmpty &&
                                  data.contains(ecController.searchString)
                              ? FontWeight.bold
                              : null),
                    );
                  }).toList()
                : data.map((String data) {
                    return ListTile(
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      dense: true,
                      title: Text(
                        data,
                        style: TextStyle(
                            fontWeight: ecController.searchString.isNotEmpty &&
                                    data.contains(ecController.searchString)
                                ? FontWeight.bold
                                : null),
                      ),
                      tileColor: ecController.searchString.isNotEmpty &&
                              data.contains(ecController.searchString)
                          ? Colors.blue
                          : null,
                      onTap: () => ecController.insertText(data + ' \n'),
                    );
                  }).toList())));
  }
}
