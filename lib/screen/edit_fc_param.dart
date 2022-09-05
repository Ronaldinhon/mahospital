import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';

import '../cameras/extract_text_camera.dart';

class EditFcParam extends StatefulWidget {
  @override
  _EditFcParamState createState() => _EditFcParamState();
}

class _EditFcParamState extends State<EditFcParam> {
  late String uid;
  double bottomHeight = 0;
  final localCont = TextEditingController();
  late CameraDescription camera;
  late List<CameraDescription> cameras;
  late RecognisedText regText;
  TextDetector _textDetector = GoogleMlKit.vision.textDetector();
  List<String> bloodParam = [
    'Hb',
    'Hct',
    'Plt',
    'Twc',
    'Na',
    'K',
    'Cl',
    'Urea',
    'Creat',
    'TProt',
    'Alb',
    'Glob',
    'TBil',
    'ALT',
    'AST',
    'ALP',
    'Ca',
    'Phos',
    'Mg',
    'CK',
    'LDH'
  ];
  late String imagePath;

  @override
  void initState() {
    uid = auth.currentUser!.uid;
    // var separateParam = 21 % 16;
    // var separateParamNum = List.generate(separateParam, (pp) => pp);
    // print(separateParamNum);
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      camera = cameras.first;
    });
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  Future<void> interpret(String path) async {
    // if (path != null) {
    var inputImage = InputImage.fromFilePath(path);
    regText = await _textDetector.processImage(inputImage);
    localCont.text = regText.text;

    // LineSplitter.split(regText.text).forEach((line) => regexIt(line));

    setState(() {
      // ptCreds = LineSplitter.split(regText.text).toList();
      bottomHeight = 200;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          height: 55,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text('Back'),
                  onPressed: () => ecController.editFCparam.value = false,
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    imagePath = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (c) {
                          return ExtractTextCamera(
                              camera, false); // need to change
                        },
                      ),
                    );
                    interpret(imagePath);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    _formKey.currentState!.save();
                    ecController.editFCparam.value = false;
                  },
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              children: bloodParam
                  .map((bp) => ParamListTile(bp, ecController.ecCorrespondKeys,
                      ecController.ecIdenTexts, localCont))
                  .toList(),
            ),
          ),
        )
      ]),
      bottomSheet: Container(
        height: bottomHeight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.red, fontSize: 10),
                      children: [
                        TextSpan(text: '* click, highlight and '),
                        WidgetSpan(
                          child: Icon(Icons.paste, size: 10, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      bottomHeight = 0;
                    });
                  },
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(6.0),
              constraints: BoxConstraints(maxHeight: 130),
              child: SingleChildScrollView(
                child: TextFormField(
                  controller: localCont,
                  decoration: InputDecoration(
                    labelText: 'Magic',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  readOnly: true,
                  showCursor: true,
                  toolbarOptions: ToolbarOptions(
                    selectAll: false,
                    copy: false,
                    cut: false,
                    paste: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParamListTile extends StatelessWidget {
  final String paramName;
  final Map fcMap;
  final List fcIden;
  final TextEditingController outsideCont;
  final controller = TextEditingController();
  // final void Function() saveFn;

  ParamListTile(this.paramName, this.fcMap, this.fcIden, this.outsideCont);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        title: Row(children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                paramName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          TextFormField(
            maxLines: 1,
            controller: controller,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              constraints: BoxConstraints(maxWidth: 200),
              isDense: true,
              prefixIcon: IconButton(
                icon: Icon(Icons.paste),
                onPressed: () async {
                  String data =
                      outsideCont.selection.textInside(outsideCont.text);
                  controller.text = data;
                },
              ),
              // border: OutlineInputBorder(
              //   borderSide: BorderSide(color: Colors.black, width: 1.0),
              // ),
              labelText: paramName,
            ),
            onSaved: (val) {
              if (val != null && val.isNotEmpty) {
                fcMap[val] = paramName;
                fcIden.add(val);
              }
            },
            onChanged: (val) => print(val),
          ),
        ]),
        subtitle: Text('Unitsss'),
      ),
    );
  }
}
