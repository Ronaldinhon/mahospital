import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';

class PtSum extends StatefulWidget {
  @override
  _PtSumState createState() => _PtSumState();
}

class _PtSumState extends State<PtSum> {
  late String uid;

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Patient Summary'),
                SizedBox(
                  height: 10,
                ),
                Text(
                  currentWPLC.cwpm.value.ptDetails(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 160,
                  ),
                  child: SingleChildScrollView(
                    reverse: false,
                    child: TextFormField(
                      controller: currentWPLC.cpCurDiag,
                      key: ValueKey('diagnosis'),
                      onChanged: (yes) => ecController.checkOnChange(),
                      decoration: InputDecoration(
                        labelText: 'Diagnosis',
                        contentPadding: const EdgeInsets.all(4.0),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 160,
                  ),
                  child: SingleChildScrollView(
                    reverse: false,
                    child: TextFormField(
                      controller: currentWPLC.cpCurPlan,
                      key: ValueKey('plan'),
                      onChanged: (yes) => ecController.checkOnChange(),
                      decoration: InputDecoration(
                        labelText: 'Plan',
                        contentPadding: const EdgeInsets.all(4.0),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                !currentWPLC.updatingPtSum.value
                    ? ElevatedButton(
                        child: Text('Save'),
                        onPressed: () => currentWPLC.savePtSum(),
                      )
                    : CircularProgressIndicator(),
                SizedBox(
                  height: 4,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.print),
                  label: Text('Print WARD Summary'),
                  onPressed: () => ecController.printingSum.value = true,
                ),
              ],
            ),
          ),
        )));
  }
}
