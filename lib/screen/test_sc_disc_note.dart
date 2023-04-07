import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/page_format.dart' as pf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import 'package:image/image.dart' as img;

class TestScDiscNote extends StatefulWidget {
  TestScDiscNote();
  @override
  _TestScDiscNoteState createState() => _TestScDiscNoteState();
}

class _TestScDiscNoteState extends State<TestScDiscNote> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  // final List<String> ptic = currentWPLC.cwpm.value.icNumber.split('');
  late List icList;
  int cmInt = 0;
  // final List<String> ptcm = currentWPLC.cwpm.value.ptComorbid;
  late List<pw.TableRow> comorbidList;
  TextEditingController spName = TextEditingController(text: '');
  TextEditingController indication = TextEditingController(text: '');
  // TextEditingController spName = TextEditingController(text: '');
  late pw.MemoryImage profileImage;
  String diag1 = '';
  String diag2 = '';
  String plan1 = '';
  String plan2 = '';
  String sum1 = '';
  String sum2 = '';
  List<String> diags = [];
  List<String> plans = [];
  List<String> sums = [];
  // late pw.PageTheme theme;
  late pw.MemoryImage profileChop;
  late pw.MemoryImage profileSignt;

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

  void generateDiagBox() {
    diags = currentWPLC.cwpm.value.curDiag.split('\n');
    // print(diags);
    if (diags.length != 0) {
      diag1 = diags.removeAt(0);
      if (getHeight(diag1, 200) < 50) {
        while (getHeight(diag1, 200) < 50) {
          if (diags.isEmpty) break;
          String tempLine = diags.removeAt(0);
          String tempDiag = diag1 + '\n' + tempLine;
          if (getHeight(tempDiag, 200) > 50) {
            diags.insert(0, tempLine);
            break;
          }
          diag1 = tempDiag;
        }
      } else {
        String excess = '';
        while (getHeight(diag1, 200) > 50) {
          var lastIndex = diag1.lastIndexOf(" ");
          if (!diag1.contains(' ')) lastIndex = diag1.length - 2;
          var just = diag1.substring(lastIndex);
          diag1 = diag1.substring(0, lastIndex);
          excess = just + excess;
        }
        diags.insert(0, excess);
      }
      if (diags.isNotEmpty) diag2 = diags.join('\n');
    }
  }

  void generatePlanBox() {
    plans = currentWPLC.cwpm.value.curPlan.split('\n');
    // print(plans);
    if (plans.length != 0) {
      plan1 = plans.removeAt(0);
      if (getHeight(plan1, 200) < 100) {
        while (getHeight(plan1, 200) < 100) {
          if (plans.isEmpty) break;
          String tempLin = plans.removeAt(0);
          String tempPlan = plan1 + '\n' + tempLin;
          if (getHeight(tempPlan, 200) > 100) {
            plans.insert(0, tempLin);
            break;
          }
          plan1 = tempPlan;
        }
      } else {
        String excess = '';
        while (getHeight(plan1, 200) > 100) {
          var lastIndex = plan1.lastIndexOf(" ");
          if (!plan1.contains(' ')) lastIndex = plan1.length - 2;
          var just = plan1.substring(lastIndex);
          plan1 = plan1.substring(0, lastIndex);
          excess = just + excess;
        }
        plans.insert(0, excess);
      }
      if (plans.isNotEmpty) plan2 = plans.join('\n');
    }
  }

  void generateSumBox() {
    sums = currentWPLC.dnoteCont.text.split('\n');
    if (sums.length != 0) {
      sum1 = sums.removeAt(0);
      if (getHeight(sum1, 200) < 395) {
        while (getHeight(sum1, 200) < 395) {
          if (sums.isEmpty) break;
          String tempSun = sums.removeAt(0);
          String tempSum = sum1 + '\n' + tempSun;
          if (getHeight(tempSum, 200) > 395) {
            sums.insert(0, tempSun);
            break;
          }
          sum1 = tempSum;
        }
      } else {
        String excess = '';
        while (getHeight(sum1, 200) > 395) {
          var lastIndex = sum1.lastIndexOf(" ");
          if (!sum1.contains(' ')) lastIndex = sum1.length - 2;
          var just = sum1.substring(lastIndex);
          sum1 = sum1.substring(0, lastIndex);
          excess = just + excess;
        }
        sums.insert(0, excess);
      }
      if (sums.isNotEmpty) sum2 = sums.join('\n');
    }
  }

  double getHeight(String sp, double width) {
    TextPainter textPainter = TextPainter()
      ..text = TextSpan(text: sp, style: TextStyle(fontSize: 9))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: width);
    return textPainter.height;
  }

  @override
  void initState() {
    super.initState();
    initImage();
    // icList = List.generate(
    //     12, (int index) => index < ptic.length ? ptic[index] : '');
    getImage();
    buildPage();
  }

  late pw.ImageProvider netImage;

  Future<void> getImage() async {
    netImage = await networkImage(
        'https://toppng.com/uploads/preview/signature-png-115539500690fdntr4lhu.png');
  }

  void buildPage() {
    pdf.addPage(pw.Page(
        pageFormat: pf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: <pw.Widget>[
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [pw.Text('Med 75 / Pindaan / 2010')]),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Stack(children: [
                pw.Text('DISCHARGE NOTE',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                // pw.Image(netImage, width: 40, height: 40),
                // pw.Transform.rotate(
                //     child: pw.Image(profileImage, width: 120, height: 120),
                //     angle: -15),
              ], alignment: pw.Alignment.center, overflow: pw.Overflow.visible)
            ]),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
            ]),
            pw.SizedBox(height: 30),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 160,
                  height: 65,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('1. NAME'),
                        pw.SizedBox(height: 2),
                        pw.Container(
                          width: 130,
                          height: 30,
                          child: pw.Text(
                              // currentWPLC.cwpm.value.name.capitalize!,
                              'xxx',
                              overflow: pw.TextOverflow.clip,
                              style: pw.TextStyle(fontSize: 9)),
                        )
                      ])),
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 100,
                  height: 65,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('2. R/N'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            // currentWPLC.cwpm.value.rNos.last,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 100,
                  height: 65,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('3. MRN'),
                        pw.Text('3. MRN lskjfs fhf f fh fhf sfslkjslkl',
                            overflow: pw.TextOverflow.visible),
                        // still disappears - need to try latest version - but in 2 column space no disappearing anymore
                      ])),
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 120,
                  height: 65,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('4. I/C NO.'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            // currentWPLC.cwpm.value.icNumber,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
            ]),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 160,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('5. SEX'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            // currentWPLC.cwpm.value.gender,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 100,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('6. AGE'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            // currentWPLC.cwpm.value.age(),
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 220,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('7. WARD'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            // currentWPLC.cwm.value.name,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
            ]),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 160,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('8. DATE OF ADMISSION'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            // currentWPLC.cwpm.value.admittedAt.last,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 320,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('9. DATE OF DISCHARGE'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            intl.DateFormat('dd/MM/yyyy')
                                .format(DateTime.now()),
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
            ]),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 480,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('10. FINAL DIAGNOSIS'),
                        pw.SizedBox(height: 2),
                        pw.Container(
                            width: 440,
                            height: 52,
                            child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(width: 15),
                                  pw.Container(
                                      child: pw.Text(diag1,
                                          overflow: pw.TextOverflow.clip,
                                          style: pw.TextStyle(fontSize: 9)),
                                      width: 200),
                                  pw.SizedBox(width: 15),
                                  pw.Container(
                                      child: pw.Text(diag2,
                                          overflow: pw.TextOverflow.clip,
                                          style: pw.TextStyle(fontSize: 9)),
                                      width: 200),
                                ]))
                      ])),
            ]),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 480,
                  height: 138,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('11. NOTES FOR FOLLOW UP, IF ANY'),
                        pw.SizedBox(height: 2),
                        pw.Container(
                            width: 440,
                            height: 102,
                            child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.SizedBox(width: 15),
                                  pw.Container(
                                      child: pw.Text(plan1,
                                          overflow: pw.TextOverflow.clip,
                                          style: pw.TextStyle(fontSize: 9)),
                                      width: 200),
                                  pw.SizedBox(width: 15),
                                  pw.Container(
                                      child: pw.Text(plan2,
                                          overflow: pw.TextOverflow.clip,
                                          style: pw.TextStyle(fontSize: 9)),
                                      width: 200),
                                ]))
                      ])),
            ]),
            pw.Row(children: [
              pw.Text('JJD009387 PNMB-JB. ', style: pw.TextStyle(fontSize: 6))
            ], mainAxisAlignment: pw.MainAxisAlignment.end),
            pw.Row(children: [pw.Text('12.')]),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              pw.Container(
                  width: 200,
                  height: 80,
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SIGNATURE'),
                        pw.Text('NAME OF MEDICAL OFFICER'),
                        pw.Text('OFFICIAL STAMP'),
                        pw.Text('DATE'),
                      ])),
              pw.Container(
                  height: 80,
                  child: pw.Stack(children: [
                    pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          pw.Text(
                              ':.......................................................................'),
                          pw.Text(
                              ':.......................................................................'),
                          pw.Text(
                              ':.......................................................................'),
                          pw.Text(
                              ':.......................................................................'),
                        ]),
                    pw.Transform.translate(
                        child: pw.Image(profileChop, width: 150, height: 150),
                        offset: PdfPoint(14, -14)),
                    pw.Image(profileSignt, width: 150, height: 150),
                    pw.Transform.translate(
                        child: pw.Text('12-12-2023'),
                        offset: PdfPoint(0, -34))
                  ])),
              // pw.Text(
              //     ':.......................................................................'),
            ]),
            // pw.Row(children: [
            //   pw.Container(
            //       width: 200,
            //       height: 20,
            //       child: pw.Text('NAME OF MEDICAL OFFICER')),
            //   pw.Text(
            //       ':.......................................................................'),
            // ]),
            // pw.Row(children: [
            //   pw.Container(
            //       width: 200, height: 20, child: pw.Text('OFFICIAL STAMP')),
            //   pw.Text(
            //       ':.......................................................................'),
            // ]),
            // pw.Row(children: [
            //   pw.Container(width: 200, height: 20, child: pw.Text('DATE')),
            //   pw.Text(
            //       ':.......................................................................'),
            // ]),
            pw.SizedBox(height: 20),
            pw.Row(children: [
              pw.Text('* RN: Encounter Number      MRN: Medical Record Number')
            ], mainAxisAlignment: pw.MainAxisAlignment.center),
            pw.SizedBox(height: 20),
            pw.Row(children: [
              pw.Text(
                  "Sila bawa bersama 'Discharge Note' semamsa susulan rawatan")
            ], mainAxisAlignment: pw.MainAxisAlignment.center),
            pw.Row(
                children: [pw.Text("Nota ini bukan untuk kegunaan Mahkamah")],
                mainAxisAlignment: pw.MainAxisAlignment.center),
          ]);
        }));

    pdf.addPage(pw.Page(
        pageFormat: pf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: <pw.Widget>[
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Text('DISCHARGE SUMMARY',
                  style:
                      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))
            ]),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PER-PD 302',
                      style: pw.TextStyle(color: PdfColors.white)),
                  pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('PER-PD 302     ',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold))
                ]),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              pw.Container(
                width: 120,
                height: 56,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                padding: pw.EdgeInsets.all(5),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('1. NAME',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 1),
                      pw.Container(
                        width: 110,
                        height: 30,
                        child: pw.Text(
                            // currentWPLC.cwpm.value.name.capitalize!,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9)),
                      )
                    ]),
              ),
              pw.Column(children: [
                pw.Container(
                    width: 80,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1,
                      ),
                    ),
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('2. R/N',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  width: 80,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      // currentWPLC.cwpm.value.rNos.last
                      'xxx'),
                )
              ]),
              pw.Column(children: [
                pw.Container(
                    width: 135,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1,
                      ),
                    ),
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('3. I/C NO.',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  width: 135,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      // currentWPLC.cwpm.value.icNumber),
                      'xxx'),
                )
              ]),
              pw.Column(children: [
                pw.Container(
                    width: 135,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1,
                      ),
                    ),
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('4. DATE OF BIRTH',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  width: 135,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      // currentWPLC.cwpm.value.birthDate),
                      'xxx'),
                )
              ]),
            ]),
            pw.Row(children: [
              pw.Container(
                width: 120,
                height: 56,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                padding: pw.EdgeInsets.all(5),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('4. ADDRESS',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 1),
                      pw.Container(
                        width: 110,
                        height: 30,
                        child: pw.Text(
                            // currentWPLC.cwpm.value.address,
                            'xxx',
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9)),
                      )
                    ]),
              ),
              pw.Column(children: [
                pw.Container(
                    width: 80,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1,
                      ),
                    ),
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('5. SEX',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  width: 80,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      // currentWPLC.cwpm.value.gender),
                      'xxx'),
                )
              ]),
              pw.Column(children: [
                pw.Container(
                    width: 135,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1,
                      ),
                    ),
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('7. DATE OF ADMISSION',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  width: 135,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      // currentWPLC.cwpm.value.admittedAt.last),
                      'xxx'),
                )
              ]),
              pw.Column(children: [
                pw.Container(
                    width: 135,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1,
                      ),
                    ),
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('8. DATE OF DISCHARGE',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold))),
                pw.Container(
                  width: 135,
                  height: 28,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  padding: pw.EdgeInsets.all(5),
                  child: pw.Text(
                      intl.DateFormat('dd/MM/yyyy').format(DateTime.now())),
                )
              ]),
            ]),
            pw.Row(children: [
              pw.Container(
                width: 120,
                height: 28,
                padding: pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                child: pw.Text('9. FINAL DIAGNOSIS',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                width: 350,
                height: 28,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                child: pw.Text(''),
              )
            ]),
            pw.Row(children: [
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                width: 470,
                height: 460,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                child: pw.Column(children: [
                  pw.Container(
                    width: 460,
                    child: pw.Text(
                        '10. SUMMARY (Including history, physical signs, relevant investigations, clinical cause, treatment, medical leave, disability etc, please use appendix if necessary)',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                      width: 420,
                      height: 400,
                      child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(width: 15),
                            pw.Container(
                                child: pw.Text(sum1,
                                    overflow: pw.TextOverflow.clip,
                                    style: pw.TextStyle(fontSize: 9)),
                                width: 200),
                            pw.SizedBox(width: 15),
                            pw.Container(
                                child: pw.Text(sum2,
                                    overflow: pw.TextOverflow.clip,
                                    style: pw.TextStyle(fontSize: 9)),
                                width: 200),
                          ]))
                ]),
              )
            ]),
            pw.Row(children: [
              pw.Container(
                width: 130,
                height: 60,
                padding: pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                child: pw.Text('11. NAME OF MEDICAL OFFICER',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Column(children: [
                pw.Container(
                  width: 210,
                  height: 30,
                  padding: pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Text(
                      '3. MRN lskjfsjlfjslfjsfjsjflsjflsjflkjflskjflsjflsjf sjlsdjflsjdfljs f lsdfjlsdjflsj slfjslfjsdl slfjslkjlksjfs 3. MRN lskjfsjlfjslfjsfjsjflsjflsjflkjflskjflsjflsjf sjlsdjflsjdfljs f lsdfjlsdjflsj slfjslfjsdl slfjslkjlksjfs'),
                ),
                pw.Container(
                  width: 210,
                  height: 30,
                  padding: pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                ),
              ]),
              pw.Column(children: [
                pw.Container(
                  width: 130,
                  height: 30,
                  padding: pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Text('12. SIGNATURE',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  width: 130,
                  height: 30,
                  padding: pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      width: 1,
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('13. DATE',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 5),
                      pw.Text(
                          intl.DateFormat('dd/MM/yyyy').format(DateTime.now()),
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(fontSize: 9))
                    ],
                  ),
                ),
              ]),
            ]),
            pw.Row(children: [
              pw.Container(
                width: 290,
                height: 30,
                padding: pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                child: pw.Text('14. OFFICIAL CHOP',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                width: 180,
                height: 30,
                padding: pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                  ),
                ),
                child: pw.Text('15. CERTIFIED BY',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ),
            ])
          ]);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PdfPreview(
        build: (format) => pdf.save(),
        onPrinted: (ctx) {},
      ),
    );
  }
}
