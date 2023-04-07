import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:get/get.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:memodx/widgets/extract_text_camera.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'dart:convert';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mahospital/cameras/extract_text_camera.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/constants/firebase.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:mahospital/models/ward_model.dart';
import 'package:mahospital/models/ward_pt_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../controllers/entry_chart_controller.dart';
import '/screen/pt_screen.dart';
import 'package:universal_html/html.dart' as html;

import 'ward_screen.dart';
import 'dart:math' as math;
import 'package:extended_masked_text/extended_masked_text.dart';

class BedScreen extends StatefulWidget {
  final BedModel bed;
  final WardModel ward;
  // final DocumentSnapshot<Object> ward;
  // final String deptId;

  BedScreen(this.bed, this.ward);
  @override
  _BedScreenState createState() => _BedScreenState();
}

class _BedScreenState extends State<BedScreen> {
  late BedModel bedModel;
  late WardModel wardModel;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // String bText = 'Add Patient';
  // late Function addPt;
  List<Widget> scanString = [];
  List<String> ptCreds = [];
  Widget qrCode = Container();
  ScrollController sCont = ScrollController();
  ScreenshotController ssCont = ScreenshotController();
  bool wardPtAdded = false;
  bool ptIni = false;

  late String uid;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();
  List<bool> isSelected = [true, false, false];
  late String race;

  late String ini;
  late String nickName;
  late List<int> regNum;

  late String name;
  late String gender;
  late String dob;
  late String doAd;
  late String ptIc;
  late String ptRN;
  late String address;

  late en.Encrypter encrypter;
  late en.Encrypted encrypted;
  late String base16;
  // String base64;
  late en.IV iv;
  late en.Key enkey;
  late String random32;
  static var _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  late CameraDescription camera;
  late List<CameraDescription> cameras;
  late String imagePath;
  final picker = ImagePicker();
  late RecognizedText regText;
  TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  // GoogleMlKit.vision.textRecognizer();

  // PersistentBottomSheetController _controllerMTFK;
  // final _formKey2 = GlobalKey<FormState>();
  // final TextEditingController _stringController = TextEditingController();

  final nameCont = TextEditingController(text: '');
  final nicknameCont = TextEditingController(text: '');
  final ptIdCont = MaskedTextController(mask: '000000-00-0000', text: '');
  final ptRnCont = TextEditingController(text: '');
  final raceCont = TextEditingController(text: '');
  final addressCont = TextEditingController(text: '');

  final dobCont = TextEditingController();
  final doAdCont = TextEditingController();
  final GlobalKey qrGlobalKey = new GlobalKey();
  final localCont = TextEditingController();
  // actually can put them into stateless widget, with map of key and 'indication string'

  @override
  void dispose() {
    nameCont.dispose();
    nicknameCont.dispose();
    ptIdCont.dispose();
    ptRnCont.dispose();
    raceCont.dispose();
    addressCont.dispose();
    dobCont.dispose();
    doAdCont.dispose();
    localCont.dispose();
    super.dispose();
  }

  @override
  void initState() {
    bedModel = widget.bed;
    wardModel = widget.ward;
    uid = auth.currentUser!.uid;
    // addPt = _trySubmit;

    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      camera = cameras.first;
    });

    doAdCont.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    super.initState();
  }

  final HttpsCallable admitWardPt = FirebaseFunctions.instance.httpsCallable(
    'admitWardPt',
  );

  // _toastInfo(String info) {
  // Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  // }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void initEncrypt() {
    random32 = getRandomString(32);
    enkey = en.Key.fromUtf8(random32);
    iv = en.IV.fromLength(16);

    encrypter = en.Encrypter(en.AES(enkey));
  }

  void _encrypt() {
    initEncrypt();
    Map toEncrypt = {
      'name': name,
      'ptIc': ptIc,
      // 'dob': dob,
    };
    encrypted = encrypter.encrypt(json.encode(toEncrypt), iv: iv);
    base16 = encrypted.base16;
  }

  // Future<String> _requestPermission() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.storage,
  //   ].request();

  //   final info = statuses[Permission.storage].toString();
  //   return info;
  // }

  void createQr() async {
    //  ini = initials(name);
    // var admitDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // String wardShortName = bed;
    // wardShortName.replaceAll(new RegExp(r"\s+"), "");
    setState(() {
      qrCode = Center(
        child: RepaintBoundary(
          key: qrGlobalKey,
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                QrImage(
                  backgroundColor: Colors.white,
                  data: base16.substring(0, 16),
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(ini),
                Text(nickName),
                Text(gender),
                Text(dob),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      );
    });
    await Future.delayed(const Duration(milliseconds: 500));
    sCont.animateTo(sCont.position.maxScrollExtent,
        duration: Duration(seconds: 1), curve: Curves.ease);
    _captureAndSavePic(ini);
  }

  Future<void> _captureAndSavePic(String ini) async {
    try {
      // RenderObject? boundary =
      //     qrGlobalKey.currentContext!.findRenderObject();
      // var image = await boundary!.toImage(pixelRatio: 1.0);
      // ByteData? byteData =
      //     await image.toByteData(format: ui.ImageByteFormat.png);

      Uint8List byteData = await ssCont.captureFromWidget(Material(
        child: qrCode,
      ));
      String base64data = base64Encode(byteData);
      html.AnchorElement a =
          html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');
      a.download = '${ini}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      a.click();
      a.remove();
      Get.snackbar(
        'Qr Image Downloaded',
        'Patient credential Qr Image downloaded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );

      // if (byteData != null) {
      //   // var ini = initials(name);
      //   // var admitDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      //   // String wardShortName = widget.ward['shortName'];
      //   // wardShortName.replaceAll(new RegExp(r"\s+"), "");
      //   final result = await ImageGallerySaver.saveImage(
      //     byteData.buffer.asUint8List(),
      //     // name: '${ini}_${wsn}_$ad'
      //   );
      //   _toastInfo(result.toString());
      // }
    } catch (e) {
      Get.snackbar(
        'Qr Download Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    }
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    // if (await _requestPermission() != 'PermissionStatus.granted') {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Local Storage permission not granted.'),
    //       backgroundColor: Theme.of(context).errorColor,
    //     ),
    //   );
    //   return;
    // }

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        _submitAuthForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Patient registration error occured. Try again or contact admin.'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    }
  }

  String initials(String name) {
    return name.split(' ').map((l) => l[0]).join();
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        dob = DateFormat('dd-MM-yyyy').format(picked);
        dobCont.text = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  _selectDateOfAd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate1, // need to make a diff 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null)
      setState(() {
        selectedDate1 = picked;
        doAd = DateFormat('dd-MM-yyyy').format(picked);
        doAdCont.text = DateFormat('dd-MM-yyyy').format(picked);
      });
  }

  Future<void> updateBed(String ptId) async {
    // await bedRef.doc(bedModel.id).update({'ptId': ptId, 'lastUpdatedBy': uid}); // in cloud function
    // var wpm = WardPtModel.fromSnapshot(await pt.get());
    var updatedBedModel =
        BedModel.fromSnapshot(await bedRef.doc(bedModel.id).get());
    await updatedBedModel.getPtModel();
    var index = currentWPLC.currentBML.indexWhere((bm) => bm.id == bedModel.id);
    currentWPLC.currentBML
        .replaceRange(index, index + 1, [updatedBedModel]); // i come back first
    if (updatedBedModel.ptInitialised) {
      currentWPLC.cbm.value = updatedBedModel;
      currentWPLC.cwpm.value = updatedBedModel.wardPtModel;
      // ptIni = true;
      Get.off(PtScreen());
    }
    // above 2 lines are so that can go to current pt
    // if not initialised how...
  }

  void _submitAuthForm() async {
    try {
      setState(() {
        _isLoading = true;
      });
      int genderIndex = isSelected.indexWhere((g) => g);
      switch (genderIndex) {
        case 0:
          gender = 'Male';
          break;
        case 1:
          gender = 'Female';
          break;
        default:
          gender = 'Agender';
      }
      ini = initials(name);
      // int age = DateTime.now().difference(selectedDate).inDays ~/ 365;
      _encrypt();

      await wardPtRef.add({
        'name': name,
        'ic': ptIc,
        'initial': ini,
        'nickName': nickName,
        'gender': genderIndex,
        'dob': dobCont.text,
        'race': race,
        'address': address,
        'random32': random32,
        'base16rmd': base16.substring(16),
        'ownerId': uid,
        'lastUpdatedBy': uid,
        'rn': [ptRN],
        'wardId': widget.ward.id,
        'deptIds': [], // leave empty until got review
        'hospId': widget.ward.hospId,
        'admittedAt': [doAdCont.text],
        'dischargedAt': [],
        'curDiag': '',
        'curPlan': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }).then((DocumentReference<Object?> pt) async {
        await bedRef
            .doc(bedModel.id)
            .update({'ptId': pt.id, 'lastUpdatedBy': uid});
        await updateBed(pt.id);
        // currentWPLC.addPtModel(wpm);
        // bedRef.doc(widget.bed.id).update({
        //   'occupied': true,
        //   'ptId': pt.id,
        //   // 'ptDetails': '$ini, ${age}yo $race $gender',
        // });
        setState(() {
          _isLoading = false;
          wardPtAdded = true;
          // bText = 'Go to $ini page';
          // addPt = () {
          //   Get.to(PtScreen());
          //   Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(
          //       builder: (c) {
          //         return PtScreen(); // need to change
          //       },
          //     ),
          //   );
          // };
          ptCreds = [];
        });
      });

      // createQr();

      // qrCode
      // the next line put in qrCode function lah
      // sCont.animateTo(sCont.position.maxScrollExtent,
      //     duration: Duration(milliseconds: 300), curve: Curves.ease);
    } on PlatformException catch (error) {
      Get.snackbar(
        'Patient creation Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Get.snackbar(
        'Patient creation Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickImage(BuildContext ctx) async {
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      // imageQuality: 50,
      // maxWidth: 150,
    );
    imagePath = pickedImage!.path;
    interpret(imagePath);
  }

  // late PersistentBottomSheetController _controller;
  // final GlobalKey globalKey = GlobalKey<ScaffoldState>();
  double bottomHeight = 0;
  final rnRegex = RegExp(r'^\d{7}$');
  final icRegex = RegExp(r'^\d{6}-\d{2}-\d{4}$');
  final ichRegex = RegExp(r'\d{12}');
  final maleRegex = RegExp(r'^LELAKI$'); //[true, false, false];
  final femaleRegex = RegExp(r'^PEREMPUAN$'); //[false, true, false];

  // final nameCont = TextEditingController(text: '');
  // final nicknameCont = TextEditingController(text: '');
  // final ptIdCont = TextEditingController(text: '');
  // final ptRnCont = TextEditingController(text: '');
  // final raceCont = TextEditingController(text: '');
  // final addressCont = TextEditingController(text: '');

  // final dobCont = TextEditingController();
  // final doAdCont = TextEditingController();

  void regexIt(String line) {
    if (rnRegex.hasMatch(line)) {
      ptRnCont.text = rnRegex.firstMatch(line)!.group(0)!;
    } else if (icRegex.hasMatch(line)) {
      String tqtq = icRegex.firstMatch(line)!.group(0)!;
      ptIdCont.text = tqtq;
      updateBithDate(tqtq);
    } else if (ichRegex.hasMatch(line)) {
      String qtqt = ichRegex.firstMatch(line)!.group(0)!;
      ptIdCont.updateText(qtqt);
      updateBithDate(qtqt);
    } else if (maleRegex.hasMatch(line)) {
      setState(() => isSelected = [true, false, false]);
    } else if (femaleRegex.hasMatch(line)) {
      setState(() => isSelected = [false, true, false]);
    }
  }

  void updateBithDate(String datee) {
    String currentYear = DateFormat('yyyy').format(DateTime.now());
    int yearNum = int.parse(currentYear.substring(2, 4));
    String birthYear = datee.substring(0, 2);
    if (int.parse(birthYear) <= yearNum) {
      birthYear = '20' + birthYear;
    } else {
      birthYear = '19' + birthYear;
    }
    String month = datee.substring(2, 4);
    String day = datee.substring(4, 6);
    dobCont.text = "$day-$month-$birthYear";
  }

  Future<void> interpret(String path) async {
    // if (path != null) {
    var inputImage = InputImage.fromFilePath(path);
    regText = await _textRecognizer.processImage(inputImage);
    localCont.text = regText.text;

    LineSplitter.split(regText.text).forEach((line) => regexIt(line));

    setState(() {
      // ptCreds = LineSplitter.split(regText.text).toList();
      bottomHeight = 200;
    });

    // globalKey.currentState!.showBottomSheet(
    //   (BuildContext context) {
    //     return ;
    //   },
    // );
    // Get.bottomSheet(
    //   Container(
    //     decoration: BoxDecoration(color: Colors.white),
    //     child:
    //     ConstrainedBox(
    //       constraints: BoxConstraints(
    //         maxHeight: 200,
    //       ),
    //       child:
    //       ListView.builder(
    //         shrinkWrap: true,
    //         itemCount: ptCreds.length,
    //         itemBuilder: (BuildContext context, int index) {
    //           return Container(
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.all(
    //                 Radius.circular(4),
    //               ),
    //               border: Border.all(
    //                 color: Colors.black,
    //                 width: 1,
    //               ),
    //             ),
    //             padding: const EdgeInsets.only(top: 4.0),
    //             margin: const EdgeInsets.all(4.0),
    //             child: ListTile(
    //               visualDensity: VisualDensity(horizontal: 0, vertical: -4),
    //               dense: true,
    //               title: Text(
    //                 ptCreds[index],
    //               ),
    //               onTap: () =>
    //                   Clipboard.setData(ClipboardData(text: ptCreds[index])),
    //             ),
    //           );
    //         },
    //         // children: scanString,
    //       ),
    //     ),
    //   ),
    //   isDismissible: false,
    //   persistent: true,
    //   backgroundColor: null
    // );

    // List<String> creds = LineSplitter.split(regText.text).toList();
    // createCards(creds);
    // }
  }

  // void createCards(List<String> creds) {
  //   ptCreds = creds;
  //   List<Widget> ltList = [];
  //   creds.asMap().forEach((i, s) {
  //     ltList.add(Padding(
  //       padding: const EdgeInsets.all(4.0),
  //       child: ListTile(
  //         title: Text(s),
  //         tileColor: Colors.blue,
  //       ),
  //     ));
  //   });
  //   setState(() {
  //     scanString = ltList;
  //   });
  // }

  void setString(int i, String s) {
    setState(() {
      ptCreds[i] = s;
    });
  }

  Future<List<WardPtModel>> _searchWardPt(
      {String field: '', String iden: ''}) async {
    if (iden.isEmpty || field.isEmpty) {
      return <WardPtModel>[];
    } else {
      List<WardPtModel> lwpm = [];
      switch (field) {
        case 'Name':
          await wardPtRef
              .where('hospId', isEqualTo: widget.ward.hospId)
              .where('name', isGreaterThanOrEqualTo: iden)
              .where('name', isLessThan: iden + 'z')
              .get()
              .then((qss) {
            qss.docs.forEach((d) {
              var wpm = WardPtModel.fromSnapshot(d);
              lwpm.add(wpm);
            });
          });

          return lwpm;
        // break;
        case 'Ic':
          await wardPtRef
              .where('hospId', isEqualTo: widget.ward.hospId)
              .where('ic', isGreaterThanOrEqualTo: iden)
              .get()
              .then((qss) {
            qss.docs.forEach((d) {
              var wpm = WardPtModel.fromSnapshot(d);
              lwpm.add(wpm);
            });
          });
          return lwpm;
        // break;
        case 'RN':
          await wardPtRef
              .where('hospId', isEqualTo: widget.ward.hospId)
              .where('rn', arrayContains: iden)
              .get()
              .then((qss) {
            qss.docs.forEach((d) {
              var wpm = WardPtModel.fromSnapshot(d);
              lwpm.add(wpm);
            });
          });
          return lwpm;
        // break;
        default:
          return lwpm;
      }
    }
  }

  final searchCont = TextEditingController();
  String searchField = '';
  String seachString = '';
  final _searchKey = GlobalKey<FormState>();
  final FocusNode fc = FocusNode();
  // Widget bottom2 = Container(
  //       decoration: BoxDecoration(color: Colors.white),
  //       child: ConstrainedBox(
  //         constraints: BoxConstraints(
  //           maxHeight: 200,
  //         ),
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: ptCreds.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             return Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.all(
  //                   Radius.circular(4),
  //                 ),
  //                 border: Border.all(
  //                   color: Colors.black,
  //                   width: 1,
  //                 ),
  //               ),
  //               padding: const EdgeInsets.only(top: 4.0),
  //               margin: const EdgeInsets.all(4.0),
  //               child: ListTile(
  //                 visualDensity: VisualDensity(horizontal: 0, vertical: -4),
  //                 dense: true,
  //                 title: Text(
  //                   ptCreds[index],
  //                 ),
  //                 onTap: () =>
  //                     Clipboard.setData(ClipboardData(text: ptCreds[index])),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        height: bottomHeight,
        // decoration: BoxDecoration(color: Colors.black),
        child:
            // ConstrainedBox(
            //   constraints: BoxConstraints(
            //     maxHeight: 200,
            //   ),
            //   child:

            //   SingleChildScrollView(
            // child:

            Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 8),
                RichText(
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
                IconButton(
                  icon: Icon(Icons.cancel),
                  // need to disable button on refresh
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

              // ListView.builder(
              //   shrinkWrap: true,
              //   itemCount: ptCreds.length,
              //   itemBuilder: (BuildContext context, int index) {
              //     return Container(
              //       decoration: BoxDecoration(
              //         // color: Colors.lightBlue, - masks inkwell effect of ListTile
              //         borderRadius: BorderRadius.all(
              //           Radius.circular(4),
              //         ),
              //         border: Border.all(
              //           color: Colors.black,
              //           width: 1,
              //         ),
              //       ),
              //       padding: const EdgeInsets.only(top: 4.0),
              //       margin: const EdgeInsets.all(8.0),
              //       child: ListTile(
              //         onTap: () => Clipboard.setData(
              //             ClipboardData(text: ptCreds[index])),
              //         visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              //         dense: true,
              //         title: Text(
              //           ptCreds[index],
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('${wardModel.shortName} - ${bedModel.name}'),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              controller: sCont,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _searchKey,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ConstrainedBox(
                        //   constraints: BoxConstraints(maxWidth: 100),
                        //   child:
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Type'),
                            style: TextStyle(color: Colors.black),
                            items: <String>['', 'Name', 'Ic', 'RN']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: searchField,
                            onChanged: (val) {
                              setState(() => searchField = val!);
                            },
                          ),
                        ),
                        // ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: searchCont,
                            onFieldSubmitted: (val) {
                              setState(() {
                                seachString = searchCont.text;
                              });
                              _searchWardPt(
                                  field: searchField, iden: seachString);
                              fc.unfocus();
                            },
                            decoration: InputDecoration(
                              labelText: 'Name/Ic/RN',
                              suffixIcon: IconButton(
                                focusNode: fc,
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    seachString = searchCont.text;
                                  });
                                  _searchWardPt(
                                      field: searchField, iden: seachString);
                                  fc.unfocus();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<List<WardPtModel>>(
                    future: _searchWardPt(
                        field: searchField, iden: searchCont.text),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<WardPtModel>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        var wardPtList = snapshot.data;
                        return Theme(
                          data: Theme.of(context).copyWith(
                              dividerTheme: DividerThemeData(
                            color: Colors.transparent,
                          )),
                          child: ExpansionTile(
                            title: Text('Search Patient List'),
                            subtitle: Text(wardPtList!.length.toString()),
                            children: wardPtList.length == 0
                                ? []
                                : wardPtList
                                    .map((wp) => ListTile(
                                          title: new Text(wp.name),
                                          // onTap: () {
                                          //   currentWPLC.addPtModel(wp);
                                          //   Get.to(PtScreen());
                                          // }
                                          trailing: wp.wardId.isNotEmpty
                                              ? Text('Admitted')
                                              : Obx(() => ElevatedButton(
                                                    child: Text('Admit'),
                                                    onPressed: currentWPLC
                                                            .aptb.value
                                                        ? null
                                                        : () async {
                                                            currentWPLC.aptb
                                                                .value = true;
                                                            await admitWardPt
                                                                .call(<String,
                                                                    dynamic>{
                                                              'wardPtId': wp.id,
                                                              'bedId':
                                                                  bedModel.id,
                                                              'admittedDate': DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(DateTime
                                                                      .now()),
                                                              'addedById': uid,
                                                            }).then((v) async {
                                                              bool success = v
                                                                  .data as bool;
                                                              if (success) {
                                                                await updateBed(
                                                                    wp.id);
                                                              } else {
                                                                Get.snackbar(
                                                                  'Error Admitting Pt',
                                                                  'Unable to admit patient to bed',
                                                                  snackPosition:
                                                                      SnackPosition
                                                                          .BOTTOM,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                );
                                                              }
                                                              currentWPLC.aptb
                                                                      .value =
                                                                  false;
                                                            }).catchError((e) {
                                                              Get.snackbar(
                                                                'Error Admitting Pt',
                                                                e.toString(),
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors.red,
                                                              );
                                                              currentWPLC.aptb
                                                                      .value =
                                                                  false;
                                                            });
                                                          },
                                                  )),
                                        ))
                                    .toList(),
                            initiallyExpanded: true,
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Create Patient',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.left, //dunno got use or not
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text('Patient Id Picture'),
                      IconButton(
                        icon: Icon(Icons.phone_android),
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
                      Transform.rotate(
                        angle: 270 * math.pi / 180,
                        child: IconButton(
                          icon: Icon(Icons.phone_android),
                          onPressed: () async {
                            imagePath = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (c) {
                                  return ExtractTextCamera(
                                      camera, true); // need to change
                                },
                              ),
                            );
                            interpret(imagePath);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.photo),
                        onPressed: () => _pickImage(context),
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          key: ValueKey('name'),
                          controller: nameCont,
                          keyboardType: TextInputType.name,
                          validator: MinLengthValidator(4,
                              errorText:
                                  'Patient Name must be at least 4 characters long'),
                          decoration: InputDecoration(
                              labelText: 'Patient Name',
                              prefixIcon: isApp
                                  ? IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        String data = localCont.selection
                                            .textInside(localCont.text);

                                        // ClipboardData? data =
                                        //     await Clipboard.getData(
                                        //         Clipboard.kTextPlain);
                                        nameCont.text += data + ' ';
                                      },
                                    )
                                  : null),
                          onSaved: (value) {
                            name = value!.trim();
                          },
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          key: ValueKey('ptIc'),
                          controller: ptIdCont,
                          keyboardType: TextInputType.text,
                          validator: MinLengthValidator(6,
                              errorText:
                                  'Patient IC must be at least 6 characters long'),
                          decoration: InputDecoration(
                              labelText: 'Patient IC',
                              prefixIcon: isApp
                                  ? IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        String data = localCont.selection
                                            .textInside(localCont.text);
                                        ptIdCont.text += data + ' ';

                                        // ClipboardData? data =
                                        //     await Clipboard.getData(
                                        //         Clipboard.kTextPlain);

                                        // ptIdCont.text += data!.text! + ' ';
                                      },
                                    )
                                  : null),
                          onSaved: (value) {
                            ptIc = value!.trim();
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          key: ValueKey('nickname'),
                          controller: nicknameCont,
                          keyboardType: TextInputType.name,
                          validator: MinLengthValidator(4,
                              errorText:
                                  'Nickname must be at least 4 characters long'),
                          decoration: InputDecoration(
                              labelText: 'Phone', //'Nickname',
                              prefixIcon: isApp
                                  ? IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        String data = localCont.selection
                                            .textInside(localCont.text);

                                        nicknameCont.text += data + ' ';
                                      },
                                    )
                                  : null),
                          onSaved: (value) {
                            nickName = value!.trim();
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          key: ValueKey('ptRN'),
                          controller: ptRnCont,
                          keyboardType: TextInputType.name,
                          validator: MinLengthValidator(6,
                              errorText:
                                  'Patient RN must be at least 6 characters long'),
                          // apparently now MinLengthValidator can detect even if field is empty now
                          decoration: InputDecoration(
                              labelText: 'Patient RN',
                              prefixIcon: isApp
                                  ? IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        String data = localCont.selection
                                            .textInside(localCont.text);

                                        ptRnCont.text += data + ' ';
                                      },
                                    )
                                  : null),
                          onSaved: (value) {
                            ptRN = value!.trim();
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ToggleButtons(
                          children: <Widget>[
                            Icon(Icons.male),
                            Icon(Icons.female),
                            Icon(Icons.transgender),
                          ],
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
                          },
                          isSelected: isSelected,
                        ),
                        TextFormField(
                          key: ValueKey('race'),
                          controller: raceCont,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              labelText: 'Patient Race',
                              prefixIcon: isApp
                                  ? IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        String data = localCont.selection
                                            .textInside(localCont.text);

                                        nameCont.text += data + ' ';
                                        // ClipboardData? data =
                                        //     await Clipboard.getData(
                                        //         Clipboard.kTextPlain);
                                        // setState(() {
                                        //   raceCont.text += data!.text! + ' ';
                                        // });
                                      },
                                    )
                                  : null),
                          onSaved: (value) {
                            race = value!.trim();
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          key: ValueKey('dob'),
                          controller: dobCont,
                          // controller: _dobController,
                          keyboardType: TextInputType.datetime,
                          validator: RequiredValidator(
                              errorText: 'Date of Birth is required'),
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                            // prefixIcon: IconButton(
                            //   icon: Icon(Icons.paste),
                            //   onPressed: () async {
                            //     ClipboardData data = await Clipboard.getData(
                            //         Clipboard.kTextPlain);
                            //     setState(() {
                            //       dobCont.text = data.text;
                            //     });
                            //   },
                            // )
                          ),
                          // onSaved: (value) {
                          //   selectedDate =
                          //       DateFormat('dd-MM-yyyy').parse(value!.trim());
                          //   dob = selectedDate.ti;
                          // },
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          key: ValueKey('address'),
                          controller: addressCont,
                          keyboardType: TextInputType.name,
                          validator: MultiValidator([
                            MinLengthValidator(8,
                                errorText:
                                    'Patient\'s Address must be at least 8 characters or shorter'),
                            PatternValidator(RegExp(r'^[\x00-\x7F]+$'),
                                errorText: 'Contains illegal character!'),
                          ]),
                          decoration: InputDecoration(
                              labelText: 'Patient\'s Address',
                              prefixIcon: isApp
                                  ? IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        String data = localCont.selection
                                            .textInside(localCont.text);
                                        addressCont.text += data + ' ';
                                        // ClipboardData? data =
                                        //     await Clipboard.getData(
                                        //         Clipboard.kTextPlain);
                                        // setState(() {
                                        //   addressCont.text += data!.text! + ' ';
                                        // });
                                      },
                                    )
                                  : null),
                          maxLines: 3,
                          onSaved: (value) {
                            address = value!;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        TextFormField(
                          key: ValueKey('doAd'),
                          controller: doAdCont,
                          keyboardType: TextInputType.datetime,
                          validator: RequiredValidator(
                              errorText: 'Date of Admission is required'),
                          decoration: InputDecoration(
                            labelText: 'Date of Admission',
                            prefixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDateOfAd(context),
                            ),
                            // prefixIcon: IconButton(
                            //   icon: Icon(Icons.paste),
                            //   onPressed: () async {
                            //     ClipboardData data = await Clipboard.getData(
                            //         Clipboard.kTextPlain);
                            //     setState(() {
                            //       dobCont.text = data.text;
                            //     });
                            //   },
                            // )
                          ),

                          // onSaved: (value) {
                          //   selectedDate =
                          //       DateFormat('dd-MM-yyyy').parse(value!.trim());
                          //   dob = selectedDate.ti;
                          // },
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        // if (_isLoading) CircularProgressIndicator(),
                        // if (!_isLoading)
                        //   !wardPtAdded
                        //       ? ElevatedButton(
                        //           onPressed: () => _trySubmit(),
                        //           child: Text('Add Patient'),
                        //         )
                        //       // : ptIni // straight away go to PtScreen in updateBed()
                        //       //     ? ElevatedButton(
                        //       //         onPressed: () => Get.off(PtScreen()),
                        //       //         child: Text('Go to $name page'),
                        //       //       )
                        //       : ElevatedButton(
                        //           onPressed: () => Get.back(),
                        //           child: Text('Go back to ward page'),
                        //         ),

                        ElevatedButton(
                          onPressed: () {
                            ecController.asdljk.add(Pt(
                                ptRnCont.text, // hNum,
                                nameCont.text, //name,
                                ptIdCont.text, // ic,
                                nicknameCont.text, // phone,
                                addressCont.text //add,
                                ));
                            nameCont.text = '';
                            nicknameCont.text = '';
                            ptIdCont.text = '';
                            ptRnCont.text = '';
                            addressCont.text = '';
                          },
                          child: Text('Save Pt'),
                        ),
                        SizedBox(
                          height: 160,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  // ConstrainedBox(
                  //   constraints: BoxConstraints(
                  //     maxHeight: 300,
                  //   ),
                  //   child: Container(
                  //     padding: EdgeInsets.only(right: 18.0),
                  //     child: ListView.builder(
                  //       shrinkWrap: true,
                  //       itemCount: ptCreds.length,
                  //       itemBuilder: (BuildContext context, int index) {
                  //         return Container(
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.all(
                  //               Radius.circular(8),
                  //             ),
                  //             border: Border.all(
                  //               color: Colors.black,
                  //               width: 1,
                  //             ),
                  //           ),
                  //           padding: const EdgeInsets.only(top: 4.0),
                  //           margin: const EdgeInsets.all(4.0),
                  //           child: ListTile(
                  //             dense: true,
                  //             title: Text(ptCreds[index]),
                  //             subtitle: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 IconButton(
                  //                   iconSize: 18,
                  //                   icon: Icon(Icons.edit, color: Colors.black),
                  //                   onPressed: () {
                  //                     _stringController.text = ptCreds[index];
                  //                     // _controllerMTFK =

                  //                     Scaffold.of(context)
                  //                         .showBottomSheet<void>(
                  //                       (BuildContext context) {
                  //                         return Container(
                  //                           padding: EdgeInsets.all(25.0),
                  //                           color: Colors.amber,
                  //                           child: Container(),
                  //                         );
                  //                       },
                  //                     );
                  //                   },
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //       // children: scanString,
                  //     ),
                  //   ),
                  // ),
                  // qrCode
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
