import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
// import 'dart:convert';
import 'dart:developer' as dev;
import 'package:image/image.dart' as img;

class IntNote extends StatefulWidget {
  IntNote();
  @override
  _IntNoteState createState() => _IntNoteState();
}

class _IntNoteState extends State<IntNote> {
  // late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  int cmInt = 0;
  late pw.MemoryImage profileChop;
  late pw.MemoryImage profileSignt;
  late String sample1;
  String sample2 = '';
  bool first = true;
  late String sample;
  List<List<String>> lisi = [];
  List<int> entryDateTime = [];
  int count = 0;
  List<String> newLines = [];
  late int numOfPg;
  bool blanking = false;
  int blankNum = 4;
  int start = 60;
  List<Map<dynamic, dynamic>> printMap = [];
  List<String> tempList = [];
  List<int> imDumb = [];
  List<String> currentData = [];
  Map<dynamic, dynamic> localMap = {};
  int pageNum = 0;
  int createdAt = 0;

  void initImage() async {
    Uint8List bytes = //(await rootBundle.load('assets/images/off_white.png'))
        ecController.cc!.buffer.asUint8List();
    Uint8List pleasemtfk = await removeWhiteBackground(bytes);
    profileChop = pw.MemoryImage(pleasemtfk);

    Uint8List byte =
        // (await rootBundle.load('assets/images/signt.png')).buffer.asUint8List();
        ecController.bb!.buffer.asUint8List();
    Uint8List pleasemtf = await removeWhiteBackground(byte);
    profileSignt = pw.MemoryImage(pleasemtf);
  }

  Future<Uint8List> removeWhiteBackground(Uint8List bytes) async {
    img.Image image = img.decodeImage(bytes)!;
    img.Image transparentImage = await colorTransparent(image, 255, 255, 255);
    var newPng = img.encodePng(transparentImage) as Uint8List;
    return newPng;
  }

  Future<img.Image> colorTransparent(
      img.Image src, int red, int green, int blue) async {
    src.channels = img.Channels.rgba;
    var pixels = src.getBytes();
    for (int i = 0, len = pixels.length; i < len; i += 4) {
      if (pixels[i] == red && pixels[i + 1] == green && pixels[i + 2] == blue) {
        pixels[i + 3] = 0;
      }
    }

    return src;
  }

  @override
  void initState() {
    // sample = currentWPLC.yeah.text;
    // lisi = sample.split('\n');
    initImage();
    List<int> trodt = currentWPLC.cwpm.value.orderedDateTime;
    List<int> rodt = trodt.reversed.toList();
    List<Map<dynamic, dynamic>> oriRec =
        []; // i am exploiting our excess to computing power
    // localMap =
    // {
    //   ...currentWPLC.cwpm.value.entries
    // };
    // new Map<dynamic, dynamic>.from(currentWPLC.cwpm.value.entries);
    localMap = json.decode(json.encode(currentWPLC.cwpm.value.entries));
    // localMap.forEach((k,m)=>m['data'] = 'ulalalalalala');
    for (int i in rodt) {
      oriRec.add(localMap[i.toString()]);
    }
    int recNum = localMap.length;
    if ((ecController.start.value < recNum) &&
        (ecController.end.value < recNum)) {
      List<int> tar = [ecController.start.value, ecController.end.value];
      tar.sort((a, b) => a.compareTo(b));
      printMap = oriRec.sublist(tar[0], tar[1] + 1);
    } else if (ecController.start.value < recNum) {
      printMap = [oriRec[ecController.start.value]];
    } else if (ecController.end.value < recNum) {
      printMap = [oriRec[ecController.end.value]];
    }
    List<int> justNum = List.generate(printMap.length, (i) => i);
    for (int ii in justNum) {
      List<String> oriData = printMap[ii]['data'].toString().split('\n');
      for (var line in oriData) {
        separateLine(line);
      }
      printMap[ii]['data'] = tempList;
      imDumb.add(tempList.length);
      tempList = [];
    }
    countPages();
    List<int> pages =
        List.generate(pageNum + 1, (i) => i); // + 1 because start with 0
    for (var pg in pages) {
      buildPage(pg);
    }
    // buildPage(0);

    // if (lisi.length != 0) {
    //   for (var line in lisi) {
    //     separateLine(line);
    //   }
    // }
    // initDownloader();

    // var rem = newLines.length % 30;
    // if (rem != 0) {
    //   numOfPg = newLines.length ~/ 30;
    //   ++numOfPg;
    // } else
    //   numOfPg = newLines.length ~/ 30;
    // List<int> pages = List.generate(numOfPg, (i) => i);
    // // print(pages.length.isEven);
    // if (pages.length.isOdd) pages.add(pages.length);
    // for (var pg in pages) {
    //   buildPage(pg);
    // }
    super.initState();
  }

  void countPages() {
    var pageLine = 30;
    print(imDumb);
    for (int ln in imDumb) {
      var lin = ln;
      do {
        pageLine -= lin;
        if (pageLine >= 8) {
          pageLine -= 4;
          lin = 0;
        } else if (pageLine < 8 && pageLine > 0) {
          // 7 or less but more than zero
          lin = 0;
          pageNum++;
          pageLine = 30;
        } else if (pageLine < 0) {
          pageNum++;
          lin = pageLine.abs();
          pageLine = 30;
        }
      } while (lin > 0);
    }
    if (pageNum.isEven) pageNum++;
    print(pageNum);
  }

  void reload() {
    List<int> trodt = currentWPLC.cwpm.value.orderedDateTime;
    List<int> rodt = trodt.reversed.toList();
    List<Map<dynamic, dynamic>> oriRec =
        []; // i am exploiting our excess to computing power
    localMap = Map<dynamic, dynamic>.from(currentWPLC.cwpm.value.entries);
    for (int i in rodt) {
      oriRec.add(localMap[i]);
    }
    int recNum = localMap.length;
    if ((ecController.start.value < recNum) &&
        (ecController.end.value < recNum)) {
      List<int> tar = [ecController.start.value, ecController.end.value];
      tar.sort((a, b) => a.compareTo(b));
      printMap = oriRec.sublist(tar[0], tar[1] + 1);
    } else if (ecController.start.value < recNum) {
      printMap = [oriRec[ecController.start.value]];
    } else if (ecController.end.value < recNum) {
      printMap = [oriRec[ecController.end.value]];
    }
    List<int> justNum = List.generate(printMap.length, (i) => i);
    for (int ii in justNum) {
      List<String> oriData = printMap[ii]['data'].toString().split('\n');
      for (var line in oriData) {
        separateLine(line);
      }
      printMap[ii]['data'] = tempList;
      imDumb.add(tempList.length);
      tempList = [];
    }
    var rem = newLines.length % 30;
    if (rem != 0) {
      numOfPg = newLines.length ~/ 30;
      ++numOfPg;
    } else
      numOfPg = newLines.length ~/ 30;
    List<int> pages = List.generate(numOfPg, (i) => i);
    // print(pages.length.isEven);
    if (pages.length.isOdd) pages.add(pages.length);
    for (var pg in pages) {
      buildPage(pg);
    }
  }

  void separateLine(String line) {
    if (getWidth(line) < 390) {
      // newLines.add(line);
      tempList.add(line);
      sample2 = '';
    } else {
      while (getWidth(line) > 390) {
        var lastIndex = line.lastIndexOf(" ");
        // lastIndex = lastIndex > 0 ? lastIndex : line.length - 2;
        if (!line.contains(' ')) lastIndex = line.length - 2;
        // print(line);
        // print(lastIndex);
        var just = line.substring(lastIndex);
        line = line.substring(0, lastIndex);
        sample2 = just + sample2;
        // print('just: ' + just);
        // print('line: ' + line);
        // print('sample2: ' + sample2);
        // dev.debugger();
      }
      // newLines.add(line);
      tempList.add(line);
      separateLine(sample2);
    }
  }

  void blankLines() {
    blanking = true;
    blankNum = 4;
    printMap.removeAt(0);
    // print(printMap.length);
  }

  String getDateTime(int ee) {
    if (printMap.isNotEmpty && ee != start + 1) {
      // while testing entry only had 1 line so the time not printed out haha (printMap empty already)
      if (ee == 1) blanking = false;
      createdAt = int.parse(printMap.first['createdAt']);
      if (currentData.isEmpty && ee < 27 && !blanking) {
        currentData = printMap.first['data'];
        // print(currentData);
        start = ee;
      }
      if (ee == start) {
        return intl.DateFormat('dd/MM/yyyy')
            .format(DateTime.fromMillisecondsSinceEpoch(createdAt));
      } else if (ee == start + 1) {
        start = 60;
        return intl.DateFormat('kk:mm')
                .format(DateTime.fromMillisecondsSinceEpoch(createdAt)) +
            'H';
      } else
        return '';
    } else if (ee == start + 1) {
      start = 60;
      return intl.DateFormat('kk:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(createdAt)) +
          'H';
    } else
      return '';
  }

  String getInLine(int ee) {
    // if (ee == 1) blanking = false;
    if (!blanking && currentData.isNotEmpty) {
      var line = currentData.removeAt(0);
      if (currentData.isEmpty) blankLines();
      // if (ee == 30 && // this if statement not working entirely wtf
      //     (printMap.isNotEmpty
      //     // || pageNum.isEven - not working
      //     )) {
      //   pageNum += 1;
      //   buildPage(pageNum);
      // }
      // print(line);
      return line;
    } else if (ee == 0 && currentData.isNotEmpty) {
      blanking = false;
      var line = currentData.removeAt(0);
      if (currentData.isEmpty) blankLines();
      // print(line);
      return line;
    } else if (ee >= 27 && blanking) {
      blankNum -= 1;
      return '';
    } else {
      blankNum -= 1;
      if (blankNum == 0) blanking = false;
      return '';
    }
  }

  List<pw.Widget> buildLines(int pgNum) {
    List<pw.Widget> lines = [];
    List n31 = List.generate(31, (i) => i);
    for (var i in n31) {
      lines.add(pw.Row(children: [
        pw.Container(
            width: 70,
            height: 20,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            )),
            child: i == 0
                ? pw.Center(
                    // padding: pw.EdgeInsets.only(left: 2, top: 3),
                    child: pw.Text('Tarikh/Masa',
                        style: pw.TextStyle(fontSize: 10)))
                : pw.Center(
                    child: pw.Text(getDateTime(i)),
                  )
            // i == 1 && pgNum == 0
            //     ? pw.Center(
            //         // padding: pw.EdgeInsets.only(left: 2, top: 3),
            //         child: pw.Text(currentWPLC.dateCont.text,
            //             style: pw.TextStyle(fontSize: 10)))
            //     : i == 2 && pgNum == 0
            //         ? pw.Center(
            //             // padding: pw.EdgeInsets.only(left: 2, top: 3),
            //             child: pw.Text(currentWPLC.timeCont.text + 'H',
            //                 style: pw.TextStyle(fontSize: 10)))
            //         : null
            ),
        pw.Container(
            padding: pw.EdgeInsets.only(left: 10, top: 3),
            width: 411,
            height: 20,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            )),
            child: i == 10
                ? pw.Transform.rotate(
                    child: pw.Image(profileChop, width: 150, height: 150),
                    angle: -0.3)
                : i == 11
                    ? pw.Transform.translate(
                        child: pw.Image(profileSignt, width: 150, height: 150),
                        offset: PdfPoint(0, 44))
                    : pw.Text(
                        // getSub()
                        getInLine(i),
                        overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(fontSize: 12)))
      ]));
    }
    // List.generate(
    //     31,
    //     (i) => lines.add(pw.Row(children: [
    //           pw.Container(
    //               width: 70,
    //               height: 20,
    //               decoration: pw.BoxDecoration(
    //                   border: pw.Border.all(
    //                 color: PdfColors.black,
    //                 width: 1,
    //               )),
    //               child: i == 0
    //                   ? pw.Center(
    //                       // padding: pw.EdgeInsets.only(left: 2, top: 3),
    //                       child: pw.Text('Tarikh/Masa',
    //                           style: pw.TextStyle(fontSize: 10)))
    //                   : i == 1 && count == 0
    //                       ? pw.Center(
    //                           // padding: pw.EdgeInsets.only(left: 2, top: 3),
    //                           child: pw.Text(currentWPLC.dateCont.text,
    //                               style: pw.TextStyle(fontSize: 10)))
    //                       : i == 2 && count == 0
    //                           ? pw.Center(
    //                               // padding: pw.EdgeInsets.only(left: 2, top: 3),
    //                               child: pw.Text(
    //                                   currentWPLC.timeCont.text + 'H',
    //                                   style: pw.TextStyle(fontSize: 10)))
    //                           : null),
    //           pw.Container(
    //               padding: pw.EdgeInsets.only(left: 10, top: 3),
    //               width: 411,
    //               height: 20,
    //               decoration: pw.BoxDecoration(
    //                   border: pw.Border.all(
    //                 color: PdfColors.black,
    //                 width: 1,
    //               )),
    //               child: i == 0 ? null : pw.Text(getSub()))
    //         ])));
    // print(lisi.length);
    return lines;
  }

  // String getSub() {
  //   // print(1);
  //   if (first) {
  //     String sam1;
  //     if (lisi.length > 0) {
  //       sam1 = lisi.removeAt(0);
  //     } else {
  //       sam1 = '';
  //     }
  //     sample1 = sam1;
  //     first = false;
  //   } else {
  //     sample1 = sample2;
  //   }
  //   if (sample1 != '') {
  //     sample2 = '';
  //     while (getWidth(sample1) > 420) {
  //       var lastIndex = sample1.lastIndexOf(" ");
  //       var just = sample1.substring(lastIndex);
  //       sample1 = sample1.substring(0, lastIndex);
  //       sample2 = just + sample2;
  //     }
  //     return sample1;
  //   } else {
  //     if (lisi.length > 0) {
  //       sample1 = lisi.removeAt(0);
  //       sample2 = '';
  //       while (getWidth(sample1) > 420) {
  //         var lastIndex = sample1.lastIndexOf(" ");
  //         var just = sample1.substring(lastIndex);
  //         sample1 = sample1.substring(0, lastIndex);
  //         sample2 = just + sample2;
  //       }
  //       return sample1;
  //     } else
  //       return '';
  //   }
  // }

  double getWidth(String sp) {
    TextPainter textPainter = TextPainter()
      ..text = TextSpan(text: sp, style: TextStyle(fontSize: 12))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  void initDownloader() async {
    // profileChop = pw.MemoryImage(
    //   (await rootBundle.load('assets/images/msia_logo.png'))
    //       .buffer
    //       .asUint8List(),
    // );
    // if (!initDownload) {
    //   initDownload = true;
    //   TextStyle();
    // }
    // if ()
  }

  Future<void> buildPage(int ind) async {
    pdf.addPage(
        pw.Page(
            pageTheme: currentWPLC.theme,
            // pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(children: <pw.Widget>[
                  pw.Text(
                    'INTEGRATED NOTES',
                    style: pw.TextStyle(
                      fontSize: 15,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    )),
                    child: pw.Column(children: buildLines(ind)),
                  ),
                  // pw.SizedBox(height: 20),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.SizedBox(
                            // height: 250,
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                              pw.SizedBox(height: 12),
                              pw.Text(
                                  'Nama : ........................................................................................          '),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                  'RN     : ........................................................................................            '),
                              pw.SizedBox(height: 12),
                              pw.Container(
                                  child: pw.Text(ecController.pgCodeCont.text,
                                      style: pw.TextStyle(fontSize: 8)),
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                          top: pw.BorderSide(width: 1)))),
                              pw.SizedBox(
                                height: 5,
                              ),
                            ])),
                        pw.Text('Pg. No.: '),
                        pw.SizedBox(width: 20),
                      ]),
                ]),
              ); // Center
            }),
        index: ind);

    // base64.encode(await pdf.save());

    // if (lisi.length > 0 || sample2.isNotEmpty || count.isEven) {
    //   count += 1;
    //   // Future.delayed(const Duration(seconds: 2), () =>
    //   buildPage(count);
    //   // );
    // }
    // print(printMap.isNotEmpty
    // print(printMap.length);
    // if (ind.isEven) buildPage(ind + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text('Back'),
                  onPressed: () => ecController.printingRec.value = false,
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text('Refresh'),
                  onPressed: () {
                    reload();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PdfPreview(
            build: (format) => pdf.save(),
          ),
        )
      ],
    );
  }
}
