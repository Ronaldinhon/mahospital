// import 'dart:math';

// import 'package:camera/camera.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:encrypt/encrypt.dart' as en;
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:memodx/screens/pt_screen.dart';
// import 'package:memodx/widgets/extract_text_camera.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:ui' as ui;
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class BedScreen extends StatefulWidget {
//   final QueryDocumentSnapshot<Object> bed;
//   final DocumentSnapshot<Object> ward;
//   final String deptId;

//   BedScreen(this.bed, this.ward, this.deptId);
//   @override
//   _BedScreenState createState() => _BedScreenState();
// }

// class _BedScreenState extends State<BedScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   String errorMessage;
//   final _auth = FirebaseAuth.instance;
//   CollectionReference ptRef = FirebaseFirestore.instance.collection('pts');
//   CollectionReference bedRef = FirebaseFirestore.instance.collection('beds');
//   final GlobalKey globalKey = new GlobalKey();
//   String bText = 'Add Patient';
//   Function addPt;
//   List<Widget> scanString = [];
//   List<String> ptCreds = [];
//   Widget qrCode = Container();
//   ScrollController sCont = ScrollController();

//   String uid;
//   // final _dobController = TextEditingController();
//   DateTime selectedDate = DateTime.now();
//   List<bool> isSelected = [true, false, false];
//   String race;

//   String name;
//   String ptId;
//   String dob;
//   String address;

//   en.Encrypter encrypter;
//   en.Encrypted encrypted;
//   String base16;
//   // String base64;
//   en.IV iv;
//   en.Key enkey;
//   String random32;
//   static var _chars =
//       'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
//   Random _rnd = Random();

//   CameraDescription camera;
//   List<CameraDescription> cameras;
//   String imagePath;
//   final picker = ImagePicker();
//   TextDetector _textDetector = GoogleMlKit.vision.textDetector();
//   RecognisedText regText;

//   // PersistentBottomSheetController _controllerMTFK;
//   final _formKey2 = GlobalKey<FormState>();
//   final TextEditingController _stringController = TextEditingController();

//   final nameCont = TextEditingController();
//   final ptIdCont = TextEditingController();
//   final raceCont = TextEditingController();
//   final dobCont = TextEditingController();
//   final addressCont = TextEditingController();
//   final GlobalKey qrGlobalKey = new GlobalKey();

//   @override
//   void initState() {
//     uid = _auth.currentUser.uid;
//     addPt = _trySubmit;

//     availableCameras().then((availableCameras) {
//       cameras = availableCameras;
//       camera = cameras.first;
//     });
//     super.initState();
//   }

//   _toastInfo(String info) {
//     Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
//   }

//   String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
//       length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

//   void initEncrypt() {
//     random32 = getRandomString(32);
//     enkey = en.Key.fromUtf8(random32);
//     iv = en.IV.fromLength(16);

//     encrypter = en.Encrypter(en.AES(enkey));
//   }

//   void _encrypt() {
//     initEncrypt();
//     Map toEncrypt = {
//       'name': name,
//       'ptId': ptId,
//       'dob': dob,
//       'address': address,
//     };
//     encrypted = encrypter.encrypt(json.encode(toEncrypt), iv: iv);
//     base16 = encrypted.base16;
//   }

//   Future<String> _requestPermission() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//     ].request();

//     final info = statuses[Permission.storage].toString();
//     return info;
//   }

//   void createQr() async {
//     String ini = initials(name);
//     var admitDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
//     String wardShortName = widget.ward['shortName'];
//     wardShortName.replaceAll(new RegExp(r"\s+"), "");
//     setState(() {
//       qrCode = Center(
//         child: RepaintBoundary(
//           key: qrGlobalKey,
//           child: Container(
//             decoration: BoxDecoration(color: Colors.white),
//             child: Column(
//               children: [
//                 QrImage(
//                   backgroundColor: Colors.white,
//                   data: base16.substring(0, 16),
//                   version: QrVersions.auto,
//                   size: 200.0,
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Text(ini),
//                 Text(dob.substring(dob.length - 5)),
//                 Text(ptId.substring(ptId.length - 5)),
//                 SizedBox(
//                   height: 5,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//     await Future.delayed(const Duration(milliseconds: 500));
//     sCont.animateTo(sCont.position.maxScrollExtent,
//         duration: Duration(seconds: 1), curve: Curves.ease);
//     _captureAndSavePic(ini, wardShortName, admitDate);
//   }

//   Future<void> _captureAndSavePic(String ini, String wsn, String ad) async {
//     try {
//       RenderRepaintBoundary boundary =
//           qrGlobalKey.currentContext.findRenderObject();
//       var image = await boundary.toImage(pixelRatio: 1.0);
//       ByteData byteData =
//           await image.toByteData(format: ui.ImageByteFormat.png);

//       if (byteData != null) {
//         // var ini = initials(name);
//         // var admitDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
//         // String wardShortName = widget.ward['shortName'];
//         // wardShortName.replaceAll(new RegExp(r"\s+"), "");
//         final result = await ImageGallerySaver.saveImage(
//           byteData.buffer.asUint8List(),
//           // name: '${ini}_${wsn}_$ad'
//         );
//         print(result.toString());
//         _toastInfo(result.toString());
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   void _trySubmit() async {
//     final isValid = _formKey.currentState.validate();
//     FocusScope.of(context).unfocus();

//     if (await _requestPermission() != 'PermissionStatus.granted') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Local Storage permission not granted.'),
//           backgroundColor: Theme.of(context).errorColor,
//         ),
//       );
//       return;
//     }

//     if (isValid) {
//       _formKey.currentState.save();
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         _submitAuthForm();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Patient registration error occured. Try again or contact admin.'),
//             backgroundColor: Theme.of(context).errorColor,
//           ),
//         );
//       }
//     }
//   }

//   String initials(String name) {
//     return name.split(' ').map((l) => l[0]).join();
//   }

//   _selectDate(BuildContext context) async {
//     final DateTime picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate, // Refer step 1
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2025),
//     );
//     if (picked != null)
//       setState(() {
//         selectedDate = picked;
//         dobCont.text = DateFormat('dd/MM/yyyy').format(picked);
//       });
//   }

//   void _submitAuthForm() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//       int genderIndex = isSelected.indexWhere((g) => g);
//       String gender;
//       switch (genderIndex) {
//         case 0:
//           gender = 'Male';
//           break;
//         case 1:
//           gender = 'Female';
//           break;
//         default:
//           gender = 'Agender';
//       }
//       String ini = initials(name);
//       int age = DateTime.now().difference(selectedDate).inDays ~/ 365;
//       _encrypt();

//       await ptRef.add({
//         // 'name': name,
//         // 'ptId': ptId,
//         // 'dob': dob,
//         // 'address': address,
//         'initial': ini,
//         'gender': genderIndex,
//         'age': age,
//         'race': race,
//         'random32': random32,
//         'base16rmd': base16.substring(16),
//         'ownerId': uid,
//         'lastUpdatedBy': uid,
//         'deptIds': [widget.deptId],
//         'wardIds': [widget.ward.id],
//         'hospId': widget.ward['hospId'],
//         'createdAt': DateTime.now().millisecondsSinceEpoch,
//         'updatedAt': DateTime.now().millisecondsSinceEpoch,
//       }).then((DocumentReference<Object> pt) {
//         bedRef.doc(widget.bed.id).update({
//           'occupied': true,
//           'ptId': pt.id,
//           'ptDetails': '$ini, ${age}yo $race $gender',
//         });
//         setState(() {
//           _isLoading = false;
//           bText = 'Go to $ini page';
//           addPt = () {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder: (c) {
//                   return PtScreen(
//                       // pt.id, widget.bed.id, widget.ward.id
//                       ); // need to change
//                 },
//               ),
//             );
//           };
//           ptCreds = [];
//         });
//       });
//       createQr();
//       // qrCode
//       // the next line put in qrCode function lah
//       // sCont.animateTo(sCont.position.maxScrollExtent,
//       //     duration: Duration(milliseconds: 300), curve: Curves.ease);
//     } on PlatformException catch (error) {
//       var message = 'Error occured. Please create patient again.';
//       if (error.message != null) {
//         message = error.message;
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Theme.of(context).errorColor,
//         ),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     } catch (error) {
//       errorMessage = error.toString() ?? 'Error occured on patient creation';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           backgroundColor: Theme.of(context).errorColor,
//         ),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _pickImage() async {
//     final pickedImage = await picker.getImage(
//       source: ImageSource.gallery,
//       // imageQuality: 50,
//       // maxWidth: 150,
//     );
//     imagePath = pickedImage?.path;
//     interpret(imagePath);
//   }

//   Future<void> interpret(String path) async {
//     if (path != null) {
//       var inputImage = InputImage.fromFilePath(path);
//       regText = await _textDetector.processImage(inputImage);
//       List<String> creds = LineSplitter.split(regText.text).toList();
//       createCards(creds);
//     }
//   }

//   void createCards(List<String> creds) {
//     ptCreds = creds;
//     List<Widget> ltList = [];
//     creds.asMap().forEach((i, s) {
//       ltList.add(Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: ListTile(
//           title: Text(s),
//           tileColor: Colors.blue,
//         ),
//       ));
//     });
//     setState(() {
//       scanString = ltList;
//     });
//   }

//   void setString(int i, String s) {
//     setState(() {
//       ptCreds[i] = s;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.bed['name']} (${widget.ward['shortName']})'),
//       ),
//       backgroundColor: Theme.of(context).primaryColor,
//       body: Center(
//         child: Card(
//           margin: EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             controller: sCont,
//             padding: EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Create Patient',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                   textAlign: TextAlign.left, //dunno got use or not
//                 ),
//                 SizedBox(
//                   height: 3,
//                 ),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       TextFormField(
//                         key: ValueKey('name'),
//                         controller: nameCont,
//                         keyboardType: TextInputType.name,
//                         validator: MinLengthValidator(4,
//                             errorText:
//                                 'Patient Name must be at least 4 characters long'),
//                         decoration: InputDecoration(
//                             labelText: 'Patient Name',
//                             prefixIcon: IconButton(
//                               icon: Icon(Icons.paste),
//                               onPressed: () async {
//                                 ClipboardData data = await Clipboard.getData(
//                                     Clipboard.kTextPlain);
//                                 setState(() {
//                                   nameCont.text = data.text;
//                                 });
//                               },
//                             )),
//                         onSaved: (value) {
//                           name = value.trim();
//                         },
//                       ),
//                       TextFormField(
//                         key: ValueKey('ptId'),
//                         controller: ptIdCont,
//                         keyboardType: TextInputType.text,
//                         validator: MinLengthValidator(6,
//                             errorText:
//                                 'Patient Id must be at least 6 characters long'),
//                         decoration: InputDecoration(
//                             labelText: 'Patient Id',
//                             prefixIcon: IconButton(
//                               icon: Icon(Icons.paste),
//                               onPressed: () async {
//                                 ClipboardData data = await Clipboard.getData(
//                                     Clipboard.kTextPlain);
//                                 setState(() {
//                                   ptIdCont.text = data.text;
//                                 });
//                               },
//                             )),
//                         onSaved: (value) {
//                           ptId = value.trim();
//                         },
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       ToggleButtons(
//                         children: <Widget>[
//                           Icon(Icons.male),
//                           Icon(Icons.female),
//                           Icon(Icons.transgender),
//                         ],
//                         onPressed: (int index) {
//                           setState(() {
//                             for (int buttonIndex = 0;
//                                 buttonIndex < isSelected.length;
//                                 buttonIndex++) {
//                               if (buttonIndex == index) {
//                                 isSelected[buttonIndex] = true;
//                               } else {
//                                 isSelected[buttonIndex] = false;
//                               }
//                             }
//                           });
//                         },
//                         isSelected: isSelected,
//                       ),
//                       TextFormField(
//                         key: ValueKey('race'),
//                         controller: raceCont,
//                         keyboardType: TextInputType.name,
//                         decoration: InputDecoration(
//                             labelText: 'Patient Race',
//                             prefixIcon: IconButton(
//                               icon: Icon(Icons.paste),
//                               onPressed: () async {
//                                 ClipboardData data = await Clipboard.getData(
//                                     Clipboard.kTextPlain);
//                                 setState(() {
//                                   raceCont.text = data.text;
//                                 });
//                               },
//                             )),
//                         onSaved: (value) {
//                           race = value.trim();
//                         },
//                       ),
//                       TextFormField(
//                         key: ValueKey('dob'),
//                         controller: dobCont,
//                         // controller: _dobController,
//                         keyboardType: TextInputType.datetime,
//                         validator: RequiredValidator(
//                             errorText: 'Date of Birth is required'),
//                         decoration: InputDecoration(
//                             labelText: 'Date of Birth',
//                             suffixIcon: IconButton(
//                               icon: Icon(Icons.calendar_today),
//                               onPressed: () => _selectDate(context),
//                             ),
//                             prefixIcon: IconButton(
//                               icon: Icon(Icons.paste),
//                               onPressed: () async {
//                                 ClipboardData data = await Clipboard.getData(
//                                     Clipboard.kTextPlain);
//                                 setState(() {
//                                   dobCont.text = data.text;
//                                 });
//                               },
//                             )),
//                         onSaved: (value) {
//                           selectedDate =
//                               DateFormat('dd/MM/yyyy').parse(value.trim());
//                           dob = value.trim();
//                         },
//                       ),
//                       TextFormField(
//                         key: ValueKey('address'),
//                         controller: addressCont,
//                         keyboardType: TextInputType.name,
//                         validator: MinLengthValidator(8,
//                             errorText:
//                                 'Patient\'s Address must be at least 8 characters or shorter'),
//                         decoration: InputDecoration(
//                             labelText: 'Patient\'s Address',
//                             prefixIcon: IconButton(
//                               icon: Icon(Icons.paste),
//                               onPressed: () async {
//                                 ClipboardData data = await Clipboard.getData(
//                                     Clipboard.kTextPlain);
//                                 setState(() {
//                                   addressCont.text = data.text;
//                                 });
//                               },
//                             )),
//                         maxLines: 3,
//                         onSaved: (value) {
//                           address = value;
//                         },
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       if (_isLoading) CircularProgressIndicator(),
//                       if (!_isLoading)
//                         ElevatedButton(
//                           onPressed: addPt,
//                           child: Text(bText),
//                         ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 8,
//                 ),
//                 Row(
//                   children: [
//                     Text('Patient Id Picture'),
//                     SizedBox(
//                       width: 15,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.camera_alt),
//                       onPressed: () async {
//                         imagePath = await Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (c) {
//                               return ExtractTextCamera(
//                                   camera); // need to change
//                             },
//                           ),
//                         );
//                         interpret(imagePath);
//                       },
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.photo),
//                       onPressed: _pickImage,
//                     ),
//                   ],
//                 ),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxHeight: 300,
//                   ),
//                   child: Container(
//                     padding: EdgeInsets.only(right: 18.0),
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: ptCreds.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(8),
//                             ),
//                             border: Border.all(
//                               color: Colors.black,
//                               width: 1,
//                             ),
//                           ),
//                           padding: const EdgeInsets.only(top: 4.0),
//                           margin: const EdgeInsets.all(4.0),
//                           child: ListTile(
//                             dense: true,
//                             // contentPadding: EdgeInsets.zero,
//                             title: Text(ptCreds[index]),
//                             // tileColor: Colors.blue,
//                             // leading:
//                             subtitle: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   iconSize: 18,
//                                   icon: Icon(Icons.edit, color: Colors.black),
//                                   onPressed: () {
//                                     _stringController.text = ptCreds[index];
//                                     // _controllerMTFK =
//                                     Scaffold.of(context).showBottomSheet<void>(
//                                       (BuildContext context) {
//                                         return Container(
//                                           padding: EdgeInsets.all(25.0),
//                                           color: Colors.amber,
//                                           child: Form(
//                                             key: _formKey2,
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: <Widget>[
//                                                 Flexible(
//                                                   flex: 1,
//                                                   child: TextFormField(
//                                                     controller:
//                                                         _stringController,
//                                                     onSaved: (String value) {
//                                                       _stringController.text =
//                                                           value;
//                                                     },
//                                                     decoration:
//                                                         const InputDecoration(
//                                                       border:
//                                                           const UnderlineInputBorder(),
//                                                       filled: true,
//                                                       hintText:
//                                                           'Type two words with space',
//                                                       labelText:
//                                                           'Seach words *',
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Flexible(
//                                                   flex: 1,
//                                                   child: ElevatedButton(
//                                                       child: const Text(
//                                                           'Close BottomSheet'),
//                                                       onPressed: () {
//                                                         _formKey2.currentState
//                                                             .save();
//                                                         setString(
//                                                             index,
//                                                             _stringController
//                                                                 .text);
//                                                         Navigator.pop(context);
//                                                       }),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                                 IconButton(
//                                   iconSize: 18,
//                                   icon: Icon(Icons.copy, color: Colors.black),
//                                   onPressed: () => Clipboard.setData(
//                                       ClipboardData(text: ptCreds[index])),
//                                 ),
//                                 IconButton(
//                                   iconSize: 18,
//                                   icon: Icon(Icons.paste, color: Colors.black),
//                                   onPressed: () async {
//                                     ClipboardData data =
//                                         await Clipboard.getData(
//                                             Clipboard.kTextPlain);
//                                     setState(() {
//                                       ptCreds[index] += ' ' + data.text;
//                                     });
//                                   },
//                                 ),
//                                 IconButton(
//                                   iconSize: 18,
//                                   icon: Icon(Icons.delete, color: Colors.black),
//                                   onPressed: () => setState(() {
//                                     ptCreds.removeAt(index);
//                                   }),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                       // children: scanString,
//                     ),
//                   ),
//                 ),
//                 qrCode
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
