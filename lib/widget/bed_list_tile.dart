import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/models/bed_model.dart';

class BedListTile extends StatelessWidget {
  final BedModel wBed;
  final int index;

  BedListTile(this.wBed, this.index, {Key? key}) : super(key: key);

//   @override
//   _BedListTileState createState() => _BedListTileState();
// }

// class _BedListTileState extends State<BedListTile> {

  @override
  Widget build(BuildContext context) {
    String ptDetails = wBed.ptInitialised ? wBed.wardPtModel.ptDetails() : '-';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.85,
      ),
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        width: 1000,
        child: ListTile(
          title: Text(wBed.name),
          subtitle: Text('Pt: ' + ptDetails),
          onTap: () {
            currentWardPtsListController.setCurrentIndex(index);


            // wBed.ptInitialised
            //     ? Get.to(PtScreen())
            //     : !wBed.error
            //         ? Get.to(BedScreen(wBed))
            //         : Get.snackbar(
            //             "Error retrieving paatient data",
            //             'Please refresh ward page.',
            //             snackPosition: SnackPosition.BOTTOM,
            //             backgroundColor: Colors.red,
            //           );


            // Provider.of<PtList>(context, listen: false)
            //     .setCurrentIndex(index);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => wBed['occupied']
            //         ? PtScreen(
            //           // wBed['ptId'], wBed.id, wBed['wardId']
            //           )
            //         : BedScreen(wBed, ward, ward['deptId']),
            //   ),
            // );
          },
        ),
      ),
    );
  }
}
