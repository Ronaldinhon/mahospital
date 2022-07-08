import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/screen/bed_screen.dart';
import 'package:mahospital/screen/pt_screen.dart';

class BedListTile extends StatelessWidget {
  final BedModel wBed;
  final WardModel wModel;
  final int index;
  final String? prevWardPtId;

  BedListTile(this.wBed, this.wModel, this.index, this.prevWardPtId, {Key? key})
      : super(key: key);

//   @override
//   _BedListTileState createState() => _BedListTileState();
// }

// class _BedListTileState extends State<BedListTile> {

  @override
  Widget build(BuildContext context) {
    String ptDetails = wBed.ptInitialised ? wBed.wardPtModel.ptDetails() : '-';

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: wBed.ptInitialised ? Colors.redAccent[400] : Colors.lightGreen,
          border: Border.all(
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      width: 1000,
      child: GestureDetector(
        onTap: () {
          // if (prevWardPtId !=
          //     null) // so that we know which position to add pt into later in bedScreen - haiz
          //   currentWPLC.setCurrentIndexByPtId(prevWardPtId!);
          if (wBed.ptInitialised) {
            currentWPLC.cbm.value = wBed;
            currentWPLC.cwpm.value = wBed.wardPtModel;
            currentWPLC.updatePtDetailsConts(wBed.wardPtModel);
          }

          wBed.ptInitialised
              ? Get.to(PtScreen())
              : !wBed.error
                  ? Get.to(BedScreen(wBed, wModel))
                  : Get.snackbar(
                      "Error retrieving patient data",
                      'Please refresh ward page.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                    );
        },
        child: GridTile(
          // header:
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wBed.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(
                  height: 4,
                ),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'O2 Port: ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      wBed.o2
                          ? WidgetSpan(
                              child: Icon(
                                Icons.check_box,
                                color: Colors.black,
                                size: 18,
                              ),
                            )
                          : WidgetSpan(
                              child: Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('Pt: '), Expanded(child: Text(ptDetails))],
                ),
              ],
            ),
          ),
          // child: SizedBox(
          //   width: 500,
          //   height: 500,
          // )
        ),
      ),
    );
  }
}
