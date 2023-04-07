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

class DiscDoc extends StatefulWidget {
  DiscDoc();
  @override
  _DiscDocState createState() => _DiscDocState();
}

class _DiscDocState extends State<DiscDoc> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  final List<String> ptic = currentWPLC.cwpm.value.icNumber.split('');
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

  void initImage() async {
    profileImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/off_white.png'))
          .buffer
          .asUint8List(),
    );

    Uint8List bytes = (await rootBundle.load('assets/images/off_white.png'))
        .buffer
        .asUint8List();
    // theme = await _myPageTheme();
    // if (!initDownload) {
    //   initDownload = true;
    //   TextStyle();
    // }

    // Uint8List bytes = (await NetworkAssetBundle(Uri.parse(
    //             'https://www.pngitem.com/pimgs/m/41-419983_transparent-signature-clipart-transparent-background-signature-png-png.png'))
    //         .load(
    //             'https://www.pngitem.com/pimgs/m/41-419983_transparent-signature-clipart-transparent-background-signature-png-png.png'))
    //     .buffer
    //     .asUint8List();
    Uint8List pleasemtfk = await removeWhiteBackground(bytes);
    print(pleasemtfk);
    profileImage = pw.MemoryImage(pleasemtfk);
  }

  // Future<pw.PageTheme> _myPageTheme() async {
  //   return pw.PageTheme(
  //     pageFormat: PdfPageFormat.standard,
  //     theme: pw.ThemeData.withFont(
  //       base: await PdfGoogleFonts.openSansRegular(),
  //       bold: await PdfGoogleFonts.openSansBold(),
  //       icons: await PdfGoogleFonts.materialIcons(),
  //     ),
  //   );
  // }

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
    // initDownloader();
    super.initState();
    initImage();
    icList = List.generate(
        12, (int index) => index < ptic.length ? ptic[index] : '');
    // comorbidList = List.generate(
    //   400,
    //   (int index) => pw.TableRow(children: [
    //     pw.Container(width: 200, child: pw.Text('iopoiu')),
    //     pw.Container(width: 200, child: pw.Text('oiuoiuoiuoiuoiuoiuo\ngjhgjh')),
    //   ]),
    // ); // ptcm
    getImage();
    generateDiagBox();
    generatePlanBox();
    generateSumBox();
    buildPage();
  }

  late pw.ImageProvider netImage;

  Future<void> getImage() async {
    netImage = await networkImage(
        'https://toppng.com/uploads/preview/signature-png-115539500690fdntr4lhu.png');
  }

  void buildPage() {
    // pdf.addPage(pw.MultiPage(
    //     pageTheme: currentWPLC.theme,
    //     build: (pw.Context context) {
    //       return [
    //         pw.Table(border: pw.TableBorder.all(), children: comorbidList)
    //       ];
    //     }));
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
                pw.Transform.rotate(
                    child: pw.Image(profileImage, width: 120, height: 120),
                    angle: -15),
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
                          // decoration: pw.BoxDecoration(
                          //   border: pw.Border.all(
                          //     width: 1,
                          //   ),
                          // ),
                          width: 130,
                          height: 30,
                          child: pw.Text(
                              currentWPLC.cwpm.value.name.capitalize!,
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
                        pw.Text(currentWPLC.cwpm.value.rNos.last,
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
                        pw.Text(
                            '3. MRN lskjfs fhf f fh fhf sfslkjslkl', overflow: pw.TextOverflow.visible),
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
                        pw.Text(currentWPLC.cwpm.value.icNumber,
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
                        pw.Text(currentWPLC.cwpm.value.gender,
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
                        pw.Text(currentWPLC.cwpm.value.age(),
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
                        pw.Text(currentWPLC.cwm.value.name,
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
                        pw.Text(currentWPLC.cwpm.value.admittedAt.last,
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
                                ])
                            // child: pw.Text(currentWPLC.cwpm.value.curDiag,
                            //     overflow: pw.TextOverflow.clip,
                            //     style: pw.TextStyle(fontSize: 9)),
                            )
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
                                ])
                            // child: pw.Text(currentWPLC.cwpm.value.curPlan,
                            //     overflow: pw.TextOverflow.clip,
                            //     style: pw.TextStyle(fontSize: 9)),
                            )
                      ])),
            ]),
            pw.Row(children: [
              pw.Text('JJD009387 PNMB-JB. ', style: pw.TextStyle(fontSize: 6))
            ], mainAxisAlignment: pw.MainAxisAlignment.end),
            pw.Row(children: [pw.Text('12.')]),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              pw.Container(width: 200, height: 20, child: pw.Text('SIGNATURE')),
              pw.Text(
                  ':.......................................................................'),
            ]),
            pw.Row(children: [
              pw.Container(
                  width: 200,
                  height: 20,
                  child: pw.Text('NAME OF MEDICAL OFFICER')),
              pw.Text(
                  ':.......................................................................'),
            ]),
            pw.Row(children: [
              pw.Container(
                  width: 200, height: 20, child: pw.Text('OFFICIAL STAMP')),
              pw.Text(
                  ':.......................................................................'),
            ]),
            pw.Row(children: [
              pw.Container(width: 200, height: 20, child: pw.Text('DATE')),
              pw.Text(
                  ':.......................................................................'),
            ]),
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
                        // decoration: pw.BoxDecoration(
                        //   border: pw.Border.all(
                        //     width: 1,
                        //   ),
                        // ),
                        width: 110,
                        height: 30,
                        child: pw.Text(currentWPLC.cwpm.value.name.capitalize!,
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
                  child: pw.Text(currentWPLC.cwpm.value.rNos.last),
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
                  child: pw.Text(currentWPLC.cwpm.value.icNumber),
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
                  child: pw.Text(currentWPLC.cwpm.value.birthDate),
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
                        // decoration: pw.BoxDecoration(
                        //   border: pw.Border.all(
                        //     width: 1,
                        //   ),
                        // ),
                        width: 110,
                        height: 30,
                        child: pw.Text(currentWPLC.cwpm.value.address,
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
                  child: pw.Text(currentWPLC.cwpm.value.gender),
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
                  child: pw.Text(currentWPLC.cwpm.value.admittedAt.last),
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
                      // decoration: pw.BoxDecoration(
                      //   border: pw.Border.all(
                      //     width: 1,
                      //   ),
                      // ),
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
                          ])
                      // pw.Text(currentWPLC.dnoteCont.text,
                      //     overflow: pw.TextOverflow.clip,
                      //     style: pw.TextStyle(fontSize: 9)),
                      )
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

    // PUT ON HOLD - KEEP IT SIMPLE FIRST
    // pdf.addPage(pw.Page(
    //         // pageFormat: pf.PdfPageFormat.a4,
    //         pageTheme: currentWPLC.theme,
    //         build: (pw.Context context) {
    //           return pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.start,
    //               children: <pw.Widget>[
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.end,
    //                     children: [pw.Text('BTS/TC/2/2016')]),
    //                 pw.SizedBox(height: 12),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.center,
    //                     children: [
    //                       pw.Text('Borang Persetujuan Pemindahan Darah',
    //                           style:
    //                               pw.TextStyle(fontWeight: pw.FontWeight.bold))
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.center,
    //                     children: [
    //                       pw.Text('Atau Kompenen Darah',
    //                           style:
    //                               pw.TextStyle(fontWeight: pw.FontWeight.bold))
    //                     ]),
    //                 pw.SizedBox(height: 12),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(width: 300),
    //                       pw.Text(
    //                         'Tarikh: ${intl.DateFormat('dd/MM/yyyy').format(DateTime.now())}',
    //                       )
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                         width: 300,
    //                         child: pw.Row(
    //                             mainAxisAlignment: pw.MainAxisAlignment.start,
    //                             crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                             children: [
    //                               pw.Text('Nama Pesakit: '),
    //                               pw.Container(
    //                                   width: 200,
    //                                   child: pw.Text(currentWPLC
    //                                       .cwpm.value.name.capitalize!))
    //                             ]),
    //                       ),
    //                       pw.Text(
    //                         'Umur: ${currentWPLC.cwpm.value.age()}',
    //                       )
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                           width: 300,
    //                           child: pw.Text(
    //                               'No. Kad Pengenalan.: ' //${currentWPLC.cwpm.value.icNumber}'
    //                               )),
    //                       pw.Text(
    //                         'Jantina: ',
    //                       ),
    //                       pw.Container(
    //                           width: 15,
    //                           height: 15,
    //                           decoration: pw.BoxDecoration(
    //                             border: pw.Border.all(
    //                               width: 1,
    //                             ),
    //                           )),
    //                       pw.Text(
    //                         ' Lelaki   ',
    //                       ),
    //                       pw.Container(
    //                         width: 15,
    //                         height: 15,
    //                         decoration: pw.BoxDecoration(
    //                           border: pw.Border.all(
    //                             width: 1,
    //                           ),
    //                         ),
    //                         child:
    //                             // pw.Center(
    //                             // child:
    //                             pw.Icon(pw.IconData(0xe5ca), size: 15)
    //                         // )
    //                         ,
    //                       ),
    //                       pw.Text(
    //                         ' Perempuan',
    //                       ),
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: icList.map((icn) {
    //                       return pw.Container(
    //                           child: pw.Center(child: pw.Text(icn)),
    //                           width: 15,
    //                           height: 15,
    //                           decoration: pw.BoxDecoration(
    //                             border: pw.Border.all(
    //                               width: 1,
    //                             ),
    //                           ));
    //                     }).toList()),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //                     children: [
    //                       pw.Container(child: pw.Text('Alamat: ')),
    //                       pw.Container(
    //                           child: pw.Text(
    //                               currentWPLC.cwpm.value.address.capitalize!)),
    //                     ]),
    //                 pw.SizedBox(height: 7),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Text('Pengamal Perubatan Yang Merawat:  Dr.'),
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Text('No. Kad Pengenalan.: '),
    //                     ]),
    //                 pw.SizedBox(height: 7),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                         width: 500,
    //                         child: pw.Text(
    //                           'Saya, seperti nema tersebut di atas/ ibu bapa/ penjaga/ suami isteri/ saudara kepada pesakit seperti nama di atas *, telah dimaklumkan bahawa pesakit memerlukan pemindahan darah atau komponen darah. Pengamal Perubatan yang merawat telah memberi penjelasan kepada saya tentang risiko dan kebaikan pemindahan darah dan saya berpuas hati dengan semua jawapan yang diberikan kepada soalan-soalan yang saya kemukakan. Saya faham dan sedar, meskipun darah atau komponen darah itu telah menjalani ujian saringan untuk HIV, Hepatitis B, Hepatitis C dan Siflis mengikut standard yang telah ditetapkan, namun risiko jangkitan penyakit menerusi pemindahan darah masih boleh berlaku. Saya juga faham dan sedar bahawa komplikasi pemindahan darah yang lain yang tidak dapat dielakkan juga mungkin berlaku. \n \nSaya benar-benar faham kenyataan di atas dan saya bersetuju untuk menerima pemindahan darah atau komponen darah.',
    //                           textAlign: pw.TextAlign.justify,
    //                           // overflow: pw.TextOverflow.span
    //                         ),
    //                       ),
    //                     ]),
    //                 pw.SizedBox(height: 25),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                       width: 300,
    //                       child: pw.Text('..............................')),
    //                   pw.Text('...............................')
    //                 ]),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                       width: 300,
    //                       child: pw.Text(
    //                           'Tanda tangan pesakit / ibu bapa / penjaga /')),
    //                   pw.Text('Tandatangan Pangamal ')
    //                 ]),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                       width: 300,
    //                       child:
    //                           pw.Text('suami / isteri / saudara terdekat.*')),
    //                   pw.Text('Perubatan yang merawat. ')
    //                 ]),
    //                 pw.SizedBox(height: 25),
    //                 pw.Row(children: [
    //                   pw.Text(
    //                       'Nama ibu bapa / penjaga / suami/ isteri / saudara terdekat**:')
    //                 ]),
    //                 pw.SizedBox(height: 10),
    //                 pw.Row(children: [pw.Text('No. Kad Pengenalan.: ')]),
    //                 pw.SizedBox(height: 20),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                         width: 500,
    //                         child: pw.Text(
    //                           'Saya memperakui makluman di atas telah diterangkan kepada pesakit/ ibu bapa/ penjaga/ suami/ isteri/ saudara terdekat yang tanda tangannya tertera di atas. Pada hemah saya penama yang dirujuk telah memahami kandungan borang ini dan telah bersetuju untuk menerima pemindahan darah atau komponen darah secara sukarela.',
    //                           textAlign: pw.TextAlign.justify,
    //                           // overflow: pw.TextOverflow.span
    //                         ),
    //                       ),
    //                     ]),
    //                 pw.SizedBox(height: 25),
    //                 pw.Text('...........................'),
    //                 pw.Text('Tanda tangan saksi'),
    //                 pw.SizedBox(height: 5),
    //                 pw.Text('Nama saksi:'),
    //                 pw.SizedBox(height: 5),
    //                 pw.Text('No. Kad Pengenalan saksi:'),
    //                 pw.SizedBox(height: 15),
    //                 pw.Text('* potong yang tidak berkaitan'),
    //                 pw.Text('** jika perlu'),
    //               ]);
    //         })
    //     // index: 0
    //     );

    // pdf.addPage(pw.Page(
    //         pageFormat: pf.PdfPageFormat.a4,
    //         build: (pw.Context context) {
    //           return pw.Column(
    //               crossAxisAlignment: pw.CrossAxisAlignment.start,
    //               children: <pw.Widget>[
    //                 pw.SizedBox(height: 8),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.end,
    //                     children: [
    //                       pw.Container(
    //                           padding: pw.EdgeInsets.all(8),
    //                           decoration: pw.BoxDecoration(
    //                               border: pw.Border.all(
    //                             color: PdfColors.black,
    //                             width: 1,
    //                           )),
    //                           child: pw.Text('HSAJB/O&G-60/VER1.0/2018')),
    //                     ]),
    //                 pw.SizedBox(height: 10),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.center,
    //                     children: [
    //                       pw.Text('EMERGENCY LSCS',
    //                           style: pw.TextStyle(
    //                               fontWeight: pw.FontWeight.bold, fontSize: 22))
    //                     ]),
    //                 pw.SizedBox(height: 15),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                           width: 200,
    //                           child: pw.Text('ORDERED BY',
    //                               style: pw.TextStyle(
    //                                   fontWeight: pw.FontWeight.bold,
    //                                   fontSize: 15))),
    //                       pw.Container(
    //                           width: 250,
    //                           decoration: pw.BoxDecoration(
    //                               border: pw.Border(
    //                                   bottom: pw.BorderSide(width: 2))),
    //                           child: pw.Text(': ${spName.text.capitalize}',
    //                               style: pw.TextStyle(
    //                                   // decoration: pw.TextDecoration.underline,
    //                                   // decorationStyle:
    //                                   //     pw.TextDecorationStyle.solid,
    //                                   fontSize: 12))),
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                           width: 200,
    //                           child: pw.Text('DATE / TIME OF BOOKING',
    //                               style: pw.TextStyle(
    //                                   fontWeight: pw.FontWeight.bold,
    //                                   fontSize: 15))),
    //                       pw.Container(
    //                           width: 250,
    //                           decoration: pw.BoxDecoration(
    //                               border: pw.Border(
    //                                   bottom: pw.BorderSide(width: 2))),
    //                           child: pw.Text(
    //                               ': ${intl.DateFormat("dd/MM/yyyy kk:mm").format(DateTime.now())}',
    //                               style: pw.TextStyle(
    //                                   // decoration: pw.TextDecoration.underline,
    //                                   // decorationStyle:
    //                                   //     pw.TextDecorationStyle.solid,
    //                                   fontSize: 12))),
    //                     ]),
    //                 pw.Row(
    //                     mainAxisAlignment: pw.MainAxisAlignment.start,
    //                     children: [
    //                       pw.Container(
    //                           width: 200,
    //                           child: pw.Text('INDICATION',
    //                               style: pw.TextStyle(
    //                                   fontWeight: pw.FontWeight.bold,
    //                                   fontSize: 15))),
    //                       pw.Container(
    //                           width: 250,
    //                           decoration: pw.BoxDecoration(
    //                               border: pw.Border(
    //                                   bottom: pw.BorderSide(width: 2))),
    //                           child: pw.Text(': ${indication.text.capitalize}',
    //                               style: pw.TextStyle(fontSize: 12))),
    //                     ]),
    //                 pw.SizedBox(height: 40),
    //                 pw.Row(children: [
    //                   pw.Text('PROBLEMS PRIOR TO LSCS',
    //                       style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold, fontSize: 15))
    //                 ]),
    //                 pw.Container(
    //                     child: pw.Column(
    //                         children: comorbidList.map((icn) {
    //                   cmInt += 1;
    //                   return pw.Row(children: [
    //                     pw.Text(cmInt.toString() + '. '),
    //                     pw.Container(
    //                         height: 20,
    //                         width: 440,
    //                         decoration: pw.BoxDecoration(
    //                             border:
    //                                 pw.Border(bottom: pw.BorderSide(width: 2))),
    //                         child:
    //                             pw.Text('', style: pw.TextStyle(fontSize: 15))),
    //                   ]);
    //                 }).toList())),
    //                 pw.SizedBox(height: 30),
    //                 pw.Text('PROBLEM ANTICIPATED DURING SURGERY',
    //                     style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold, fontSize: 15)),
    //                 pw.Container(
    //                     width: 440,
    //                     height: 22,
    //                     padding: pw.EdgeInsets.only(top: 7),
    //                     decoration: pw.BoxDecoration(
    //                         border: pw.Border(bottom: pw.BorderSide(width: 2))),
    //                     child: pw.Text(
    //                         '  Risk of bleeding requiring blood tranfusion',
    //                         style: pw.TextStyle(fontSize: 12))),
    //                 pw.Container(
    //                     width: 440,
    //                     height: 22,
    //                     padding: pw.EdgeInsets.only(top: 7),
    //                     decoration: pw.BoxDecoration(
    //                         border: pw.Border(bottom: pw.BorderSide(width: 2))),
    //                     child: pw.Text(
    //                         '  Risk of injury to bowel, bladder and ureter',
    //                         style: pw.TextStyle(fontSize: 12))),
    //                 pw.Container(
    //                     width: 440,
    //                     height: 22,
    //                     padding: pw.EdgeInsets.only(top: 7),
    //                     decoration: pw.BoxDecoration(
    //                         border: pw.Border(bottom: pw.BorderSide(width: 2))),
    //                     child: pw.Text('  Risk of injury to fetus',
    //                         style: pw.TextStyle(fontSize: 12))),
    //                 pw.Container(
    //                     width: 440,
    //                     height: 22,
    //                     padding: pw.EdgeInsets.only(top: 7),
    //                     decoration: pw.BoxDecoration(
    //                         border: pw.Border(bottom: pw.BorderSide(width: 2))),
    //                     child: pw.Text('  Risk of anaesthesia',
    //                         style: pw.TextStyle(fontSize: 12))),
    //                 pw.Container(
    //                     width: 440,
    //                     height: 22,
    //                     padding: pw.EdgeInsets.only(top: 7),
    //                     decoration: pw.BoxDecoration(
    //                         border: pw.Border(bottom: pw.BorderSide(width: 2))),
    //                     child: pw.Text('  Risk of venous thromboembolism',
    //                         style: pw.TextStyle(fontSize: 12))),
    //                 pw.SizedBox(height: 25),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                     width: 300,
    //                     child: pw.Text('SURGEON',
    //                         style: pw.TextStyle(
    //                             fontWeight: pw.FontWeight.bold, fontSize: 15)),
    //                   ),
    //                   pw.Text('WITNESSED BY',
    //                       style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold, fontSize: 15))
    //                 ]),
    //                 pw.SizedBox(height: 20),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                     width: 300,
    //                     child: pw.Text('.................................',
    //                         style: pw.TextStyle(
    //                             fontWeight: pw.FontWeight.bold, fontSize: 15)),
    //                   ),
    //                   pw.Text('.................................',
    //                       style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold, fontSize: 15))
    //                 ]),
    //                 pw.SizedBox(height: 10),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                     width: 300,
    //                     child: pw.Text('NAME',
    //                         style: pw.TextStyle(
    //                             fontWeight: pw.FontWeight.bold, fontSize: 15)),
    //                   ),
    //                   pw.Text('NAME',
    //                       style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold, fontSize: 15))
    //                 ]),
    //                 pw.Row(children: [
    //                   pw.Container(
    //                     width: 300,
    //                     child: pw.Text('DATE / TIME',
    //                         style: pw.TextStyle(
    //                             fontWeight: pw.FontWeight.bold, fontSize: 15)),
    //                   ),
    //                   pw.Text('DATE / TIME',
    //                       style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold, fontSize: 15))
    //                 ]),
    //               ]);
    //         })
    //     // index: 0
    //     );
  }

  // void initDownloader() async {
  //   profileImage = pw.MemoryImage(
  //     (await rootBundle.load('assets/images/msia_logo.png'))
  //         .buffer
  //         .asUint8List(),
  //   );
  //   // theme = await _myPageTheme();
  //   if (!initDownload) {
  //     initDownload = true;
  //     TextStyle();
  //   }
  // }

  // Future<nat.PdfController> createDoc() async {
  //   pdf.addPage(
  //       pw.Page(
  //           pageFormat: pf.PdfPageFormat.a4,
  //           build: (pw.Context context) {
  //             return pw.Center(
  //               child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                   children: <pw.Widget>[
  //                     pw.Text('DISCHARGE NOTE'),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU'),
  //                     pw.SizedBox(height: 20),
  //                     pw.Row(children: [
  //                       pw.Container(
  //                           decoration: pw.BoxDecoration(
  //                               border: pw.Border.all(
  //                             color: PdfColors.black,
  //                             width: 1,
  //                           )),
  //                           width: 160,
  //                           height: 100,
  //                           padding: pw.EdgeInsets.all(8.0),
  //                           child: pw.Column(
  //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                               children: [
  //                                 pw.Text('1. NAME'),
  //                                 pw.Text('Chao Tao Xin'),
  //                               ])),
  //                       pw.Container(
  //                           decoration: pw.BoxDecoration(
  //                               border: pw.Border.all(
  //                             color: PdfColors.black,
  //                             width: 1,
  //                           )),
  //                           width: 100,
  //                           height: 100,
  //                           padding: pw.EdgeInsets.all(8.0),
  //                           child: pw.Column(
  //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                               children: [
  //                                 pw.Text('2. R/N'),
  //                                 pw.Text('2015295'),
  //                               ])),
  //                       pw.Container(
  //                           decoration: pw.BoxDecoration(
  //                               border: pw.Border.all(
  //                             color: PdfColors.black,
  //                             width: 1,
  //                           )),
  //                           width: 100,
  //                           height: 100,
  //                           padding: pw.EdgeInsets.all(8.0),
  //                           child: pw.Column(
  //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                               children: [
  //                                 pw.Text('3. MRN'),
  //                                 // pw.Text('2015295'),
  //                               ])),
  //                       pw.Container(
  //                           decoration: pw.BoxDecoration(
  //                               border: pw.Border.all(
  //                             color: PdfColors.black,
  //                             width: 1,
  //                           )),
  //                           width: 120,
  //                           height: 100,
  //                           padding: pw.EdgeInsets.all(8.0),
  //                           child: pw.Column(
  //                               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                               children: [
  //                                 pw.Text('4. I/C NO.'),
  //                                 pw.Text('960414-04-1414'),
  //                               ])),
  //                     ])
  //                   ]),
  //             ); // Center
  //           }),
  //       index: 0);
  //   pdf.addPage(
  //       pw.Page(
  //           pageFormat: pf.PdfPageFormat.a4,
  //           build: (pw.Context context) {
  //             return pw.Center(
  //               child: pw.Column(children: <pw.Widget>[
  //                 pw.Text('DISCHARGE NOTE'),
  //                 pw.SizedBox(height: 10),
  //                 pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU'),
  //                 pw.SizedBox(height: 20),
  //                 pw.Row(children: [
  //                   pw.Container(
  //                       decoration: pw.BoxDecoration(
  //                           border: pw.Border.all(
  //                         color: PdfColors.black,
  //                         width: 1,
  //                       )),
  //                       width: 160,
  //                       height: 100,
  //                       padding: pw.EdgeInsets.all(8.0),
  //                       child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                           children: [
  //                             pw.Text('1. NAME'),
  //                             pw.Text('Chao Tao Xin'),
  //                           ])),
  //                   pw.Container(
  //                       decoration: pw.BoxDecoration(
  //                           border: pw.Border.all(
  //                         color: PdfColors.black,
  //                         width: 1,
  //                       )),
  //                       width: 100,
  //                       height: 100,
  //                       padding: pw.EdgeInsets.all(8.0),
  //                       child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                           children: [
  //                             pw.Text('2. R/N'),
  //                             pw.Text('2015295'),
  //                           ])),
  //                   pw.Container(
  //                       decoration: pw.BoxDecoration(
  //                           border: pw.Border.all(
  //                         color: PdfColors.black,
  //                         width: 1,
  //                       )),
  //                       width: 100,
  //                       height: 100,
  //                       padding: pw.EdgeInsets.all(8.0),
  //                       child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                           children: [
  //                             pw.Text('3. MRN'),
  //                             // pw.Text('2015295'),
  //                           ])),
  //                   pw.Container(
  //                       decoration: pw.BoxDecoration(
  //                           border: pw.Border.all(
  //                         color: PdfColors.black,
  //                         width: 1,
  //                       )),
  //                       width: 120,
  //                       height: 100,
  //                       padding: pw.EdgeInsets.all(8.0),
  //                       child: pw.Column(
  //                           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                           children: [
  //                             pw.Text('4. I/C NO.'),
  //                             pw.Text('960414-04-1414'),
  //                           ])),
  //                 ])
  //               ]),
  //             );
  //           }),
  //       index: 1);
  //   pdfController = nat.PdfController(
  //     document: nat.PdfDocument.openData(await pdf.save()),
  //   );
  //   return pdfController;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PdfPreview(
        build: (format) => pdf.save(),
        onPrinted: (ctx){},
      ),
      //     child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //     SizedBox(
      //       height: 50,
      //       child: Padding(
      //         padding: const EdgeInsets.all(6.0),
      //         child: ElevatedButton(
      //           child: Text('Back'),
      //           onPressed: () => ecController.printingDisc.value = false,
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       child:
      //       PdfPreview(
      //         build: (format) => pdf.save(),
      //       ),
      //     )
      //   ],
      // ),
    );
  }
}
