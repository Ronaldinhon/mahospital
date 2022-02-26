import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IntNote extends StatefulWidget {
  IntNote();
  @override
  _IntNoteState createState() => _IntNoteState();
}

class _IntNoteState extends State<IntNote> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  int cmInt = 0;
  late pw.MemoryImage profileImage;
  late String sample1;
  String sample2 = '';
  bool first = true;
  // final
  late String sample;
  // 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages.\n\nFirst separated line.\n\nSecond separated line~~';
  late List<String> lisi;
  int count = 0;
  List<String> newLines = [];
  late int numOfPg;

  @override
  void initState() {
    sample = currentWPLC.yeah.text;
    lisi = sample.split('\n');
    if (lisi.length != 0) {
      for (var line in lisi) {
        separateLine(line);
      }
    }
    // initDownloader();
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
    super.initState();
  }

  void reload() {
    sample = currentWPLC.yeah.text;
    lisi = sample.split('\n');
    if (lisi.length != 0) {
      for (var line in lisi) {
        separateLine(line);
      }
    }
    // initDownloader();
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
    if (getWidth(line) < 420) {
      newLines.add(line);
    } else {
      while (getWidth(line) > 420) {
        var lastIndex = line.lastIndexOf(" ");
        var just = line.substring(lastIndex);
        line = line.substring(0, lastIndex);
        sample2 = just + sample2;
      }
      newLines.add(line);
      separateLine(sample2);
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
                : i == 1 && pgNum == 0
                    ? pw.Center(
                        // padding: pw.EdgeInsets.only(left: 2, top: 3),
                        child: pw.Text(currentWPLC.dateCont.text,
                            style: pw.TextStyle(fontSize: 10)))
                    : i == 2 && pgNum == 0
                        ? pw.Center(
                            // padding: pw.EdgeInsets.only(left: 2, top: 3),
                            child: pw.Text(currentWPLC.timeCont.text + 'H',
                                style: pw.TextStyle(fontSize: 10)))
                        : null),
        pw.Container(
            padding: pw.EdgeInsets.only(left: 10, top: 3),
            width: 411,
            height: 20,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            )),
            child: i == 0 || newLines.length == 0 ? null : pw.Text(
                // getSub()
                newLines.removeAt(0)))
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

  String getSub() {
    // print(1);
    if (first) {
      String sam1;
      if (lisi.length > 0) {
        sam1 = lisi.removeAt(0);
      } else {
        sam1 = '';
      }
      sample1 = sam1;
      first = false;
    } else {
      sample1 = sample2;
    }
    if (sample1 != '') {
      sample2 = '';
      while (getWidth(sample1) > 420) {
        var lastIndex = sample1.lastIndexOf(" ");
        var just = sample1.substring(lastIndex);
        sample1 = sample1.substring(0, lastIndex);
        sample2 = just + sample2;
      }
      return sample1;
    } else {
      if (lisi.length > 0) {
        sample1 = lisi.removeAt(0);
        sample2 = '';
        while (getWidth(sample1) > 420) {
          var lastIndex = sample1.lastIndexOf(" ");
          var just = sample1.substring(lastIndex);
          sample1 = sample1.substring(0, lastIndex);
          sample2 = just + sample2;
        }
        return sample1;
      } else
        return '';
    }
  }

  double getWidth(String sp) {
    TextPainter textPainter = TextPainter()
      ..text = TextSpan(text: sp)
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  void initDownloader() async {
    // profileImage = pw.MemoryImage(
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

  void buildPage(int ind) {
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
                                  child: pw.Text('JJT21 0117 PNMB-JB.',
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
    // if (lisi.length > 0 || sample2.isNotEmpty || count.isEven) {
    //   count += 1;
    //   // Future.delayed(const Duration(seconds: 2), () =>
    //   buildPage(count);
    //   // );
    // }
    // print(lisi.length);
    // if (lisi.length > 0) buildPage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: ElevatedButton(
              child: Text('Refresh'),
              onPressed: () {
                reload();
                setState(() {});
              },
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
