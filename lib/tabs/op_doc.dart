import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/page_format.dart' as pf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class OpDoc extends StatefulWidget {
  OpDoc();
  @override
  _OpDocState createState() => _OpDocState();
}

class _OpDocState extends State<OpDoc> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  final List<String> ptic = currentWPLC.cwpm.value.icNumber.split('');
  late List icList;
  int cmInt = 0;
  // final List<String> ptcm = currentWPLC.cwpm.value.ptComorbid;
  late List<String> comorbidList;
  TextEditingController spName = TextEditingController(text: '');
  TextEditingController indication = TextEditingController(text: '');
  // TextEditingController spName = TextEditingController(text: '');
  late pw.MemoryImage profileImage;
  // late pw.PageTheme theme;

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

  List<pw.Widget> buildLines() {
    List<pw.Widget> lines = [];
    List.generate(
        16,
        (i) => lines.add(pw.Row(children: [
              pw.Container(
                padding: pw.EdgeInsets.only(left: 10, top: 3),
                width: 411,
                height: 20,
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                  color: PdfColors.black,
                  width: 1,
                )),
                // child: i == 0 ? null : pw.Text(getSub())
              )
            ])));
    // print(lisi.length);
    return lines;
  }

  @override
  void initState() {
    initDownloader();
    super.initState();
    icList = List.generate(
        12, (int index) => index < ptic.length ? ptic[index] : '');
    comorbidList = List.generate(5, (int index) => ''); // ptcm

    pdf.addPage(pw.Page(
        pageFormat: pf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: <pw.Widget>[
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [pw.Text('Med 75 / Pindaan / 2010')]),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              pw.Text('DISCHARGE NOTE',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
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
                          child: pw.Text(currentWPLC.dnameCont.text,
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
                        pw.Text(currentWPLC.drnCont.text,
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
                        pw.Text(currentWPLC.dicCont.text,
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
                        pw.Text(currentWPLC.dsexCont.text,
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
                        pw.Text(currentWPLC.dageCont.text,
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
                        pw.Text(currentWPLC.dwardCont.text,
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
                        pw.Text(currentWPLC.ddoaCont.text,
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
                        pw.Text(currentWPLC.ddodCont.text,
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 9))
                      ])),
            ]),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 480,
                  height: 65,
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
                          // decoration: pw.BoxDecoration(
                          //   border: pw.Border.all(
                          //     width: 1,
                          //   ),
                          // ),
                          width: 330,
                          height: 33,
                          child: pw.Text(currentWPLC.dfdxCont.text,
                              overflow: pw.TextOverflow.clip,
                              style: pw.TextStyle(fontSize: 9)),
                        )
                      ])),
            ]),
            pw.Row(children: [
              pw.Container(
                  padding: pw.EdgeInsets.all(5),
                  width: 480,
                  height: 110,
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
                          // decoration: pw.BoxDecoration(
                          //   border: pw.Border.all(
                          //     width: 1,
                          //   ),
                          // ),
                          width: 330,
                          height: 75,
                          child: pw.Text(currentWPLC.dfupCont.text,
                              overflow: pw.TextOverflow.clip,
                              style: pw.TextStyle(fontSize: 9)),
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
    // pdf.addPage(pw.Page(
    //     pageFormat: pf.PdfPageFormat.a4,
    //     build: (pw.Context context) {
    //       return pw.Column(children: <pw.Widget>[
    //         pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
    //           pw.Container(height: 40, width: 40, child: pw.Image(profileImage))
    //         ]),
    //         pw.Row(
    //             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
    //             children: [
    //               pw.Text('HOSPITAL '),
    //               pw.Container(
    //                 width: 250,
    //                 decoration: pw.BoxDecoration(
    //                     border: pw.Border(bottom: pw.BorderSide(width: 2))),
    //               ),
    //             ]),
    //       ]);
    //     }));

    // pdf.addPage(pw.Page(
    //     pageTheme: currentWPLC.theme,
    //     build: (pw.Context context) {
    //       return pw.Column(children: <pw.Widget>[
    //         pw.Row(
    //             children: [pw.Text('LAMPIRAN')],
    //             mainAxisAlignment: pw.MainAxisAlignment.end),
    //         pw.Row(children: [
    //           pw.Text('KEMENTERIAN KESIHATAN MALAYSIA',
    //               style:
    //                   pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))
    //         ], mainAxisAlignment: pw.MainAxisAlignment.center),
    //         pw.Row(children: [
    //           pw.Text('SURAT RUJUKAN',
    //               style:
    //                   pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))
    //         ], mainAxisAlignment: pw.MainAxisAlignment.center),
    //         pw.SizedBox(height: 6),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 411,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child:
    //                 pw.Text('Rujukan mestilah kepada Pakar/Penguna Perubatan',
    //                     style: pw.TextStyle(
    //                       fontWeight: pw.FontWeight.bold,
    //                     ))),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Row(children: [
    //               pw.Container(
    //                   child: pw.Text('Kepada',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       ))),
    //               pw.Container(
    //                 width: 16,
    //                 height: 30,
    //                 margin: pw.EdgeInsets.all(2),
    //                 decoration: pw.BoxDecoration(
    //                     border: pw.Border.all(
    //                   color: PdfColors.black,
    //                   width: 1,
    //                 )),
    //               ),
    //               pw.Text('  Segera',
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                   ))
    //             ])),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Row(children: [
    //               pw.Container(
    //                   child: pw.Text('Jabatan/Unit :',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       ))),
    //               pw.Container(
    //                 width: 16,
    //                 height: 30,
    //                 margin: pw.EdgeInsets.all(2),
    //                 decoration: pw.BoxDecoration(
    //                     border: pw.Border.all(
    //                   color: PdfColors.black,
    //                   width: 1,
    //                 )),
    //               ),
    //               pw.Text('  Tidak segera mengikut penempatan',
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                   ))
    //             ])),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Row(children: [
    //               pw.Container(
    //                   child: pw.Text('Nama Pesakit :',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       ))),
    //               pw.Container(width: 80, height: 30, child: pw.Text('Umur :')),
    //               pw.Text('Jantina :',
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                   ))
    //             ])),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Row(children: [
    //               pw.Container(
    //                   child: pw.Text('No. K.P :',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       ))),
    //               pw.Text('No. Rujukan :',
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                   ))
    //             ])),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Row(children: [
    //               pw.Container(
    //                   child: pw.Text('Tarikh :',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       ))),
    //               pw.Text('Masa :',
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                   ))
    //             ])),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 20,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Row(children: [
    //               pw.Text('History :',
    //                   style: pw.TextStyle(
    //                     fontWeight: pw.FontWeight.bold,
    //                   ))
    //             ])),
    //         ...buildLines(),
    //         pw.Container(
    //             padding: pw.EdgeInsets.only(left: 10, top: 3),
    //             width: 430,
    //             height: 82,
    //             decoration: pw.BoxDecoration(
    //                 border: pw.Border.all(
    //               color: PdfColors.black,
    //               width: 1,
    //             )),
    //             child: pw.Column(
    //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   pw.Text('History :',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       )),
    //                   pw.Row(children: [
    //                     pw.Container(
    //                       width: 240,
    //                       child: pw.Text('Nama :',
    //                           style: pw.TextStyle(
    //                             fontWeight: pw.FontWeight.bold,
    //                           )),
    //                     ),
    //                     pw.Text('Tandatangan :',
    //                         style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold,
    //                         )),
    //                   ]),
    //                   pw.Row(children: [
    //                     pw.Container(
    //                       width: 240,
    //                       child: pw.Text('Jabatan/Unit :',
    //                           style: pw.TextStyle(
    //                             fontWeight: pw.FontWeight.bold,
    //                           )),
    //                     ),
    //                     pw.Text('Tel. :',
    //                         style: pw.TextStyle(
    //                           fontWeight: pw.FontWeight.bold,
    //                         )),
    //                   ]),
    //                   pw.Text('Hospital :',
    //                       style: pw.TextStyle(
    //                         fontWeight: pw.FontWeight.bold,
    //                       )),
    //                 ])),
    //       ]);
    //     }));

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
                        child: pw.Text(currentWPLC.dnameCont.text,
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
                  child: pw.Text(currentWPLC.drnCont.text),
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
                  child: pw.Text(currentWPLC.dicCont.text),
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
                  child: pw.Text(currentWPLC.ddobCont.text),
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
                        child: pw.Text(currentWPLC.daddCont.text,
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
                  child: pw.Text(currentWPLC.dsexCont.text),
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
                  child: pw.Text(currentWPLC.ddoaCont.text),
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
                  child: pw.Text(currentWPLC.ddodCont.text),
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
                    child: pw.Text(currentWPLC.dnoteCont.text,
                        overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(fontSize: 9)),
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
                  child: pw.Text('13. DATE',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
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
    pdf.addPage(pw.Page(
            // pageFormat: pf.PdfPageFormat.a4,
            pageTheme: currentWPLC.theme,
            build: (pw.Context context) {
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [pw.Text('BTS/TC/2/2016')]),
                    pw.SizedBox(height: 12),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Borang Persetujuan Pemindahan Darah',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold))
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Atau Kompenen Darah',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold))
                        ]),
                    pw.SizedBox(height: 12),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(width: 300),
                          pw.Text(
                            'Tarikh: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                          )
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 300,
                            child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Nama Pesakit: '),
                                  pw.Container(
                                      width: 200,
                                      child: pw.Text(currentWPLC
                                          .cwpm.value.name.capitalize!))
                                ]),
                          ),
                          pw.Text(
                            'Umur: ${currentWPLC.cwpm.value.age()}',
                          )
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                              width: 300,
                              child: pw.Text(
                                  'No. Kad Pengenalan.: ' //${currentWPLC.cwpm.value.icNumber}'
                                  )),
                          pw.Text(
                            'Jantina: ',
                          ),
                          pw.Container(
                              width: 15,
                              height: 15,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  width: 1,
                                ),
                              )),
                          pw.Text(
                            ' Lelaki   ',
                          ),
                          pw.Container(
                            width: 15,
                            height: 15,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 1,
                              ),
                            ),
                            child:
                                // pw.Center(
                                // child:
                                pw.Icon(pw.IconData(0xe5ca), size: 15)
                            // )
                            ,
                          ),
                          pw.Text(
                            ' Perempuan',
                          ),
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: icList.map((icn) {
                          return pw.Container(
                              child: pw.Center(child: pw.Text(icn)),
                              width: 15,
                              height: 15,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  width: 1,
                                ),
                              ));
                        }).toList()),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(child: pw.Text('Alamat: ')),
                          pw.Container(
                              child: pw.Text(
                                  currentWPLC.cwpm.value.address.capitalize!)),
                        ]),
                    pw.SizedBox(height: 7),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text('Pengamal Perubatan Yang Merawat:  Dr.'),
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text('No. Kad Pengenalan.: '),
                        ]),
                    pw.SizedBox(height: 7),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 500,
                            child: pw.Text(
                              'Saya, seperti nema tersebut di atas/ ibu bapa/ penjaga/ suami isteri/ saudara kepada pesakit seperti nama di atas *, telah dimaklumkan bahawa pesakit memerlukan pemindahan darah atau komponen darah. Pengamal Perubatan yang merawat telah memberi penjelasan kepada saya tentang risiko dan kebaikan pemindahan darah dan saya berpuas hati dengan semua jawapan yang diberikan kepada soalan-soalan yang saya kemukakan. Saya faham dan sedar, meskipun darah atau komponen darah itu telah menjalani ujian saringan untuk HIV, Hepatitis B, Hepatitis C dan Siflis mengikut standard yang telah ditetapkan, namun risiko jangkitan penyakit menerusi pemindahan darah masih boleh berlaku. Saya juga faham dan sedar bahawa komplikasi pemindahan darah yang lain yang tidak dapat dielakkan juga mungkin berlaku. \n \nSaya benar-benar faham kenyataan di atas dan saya bersetuju untuk menerima pemindahan darah atau komponen darah.',
                              textAlign: pw.TextAlign.justify,
                              // overflow: pw.TextOverflow.span
                            ),
                          ),
                        ]),
                    pw.SizedBox(height: 25),
                    pw.Row(children: [
                      pw.Container(
                          width: 300,
                          child: pw.Text('..............................')),
                      pw.Text('...............................')
                    ]),
                    pw.Row(children: [
                      pw.Container(
                          width: 300,
                          child: pw.Text(
                              'Tanda tangan pesakit / ibu bapa / penjaga /')),
                      pw.Text('Tandatangan Pangamal ')
                    ]),
                    pw.Row(children: [
                      pw.Container(
                          width: 300,
                          child:
                              pw.Text('suami / isteri / saudara terdekat.*')),
                      pw.Text('Perubatan yang merawat. ')
                    ]),
                    pw.SizedBox(height: 25),
                    pw.Row(children: [
                      pw.Text(
                          'Nama ibu bapa / penjaga / suami/ isteri / saudara terdekat**:')
                    ]),
                    pw.SizedBox(height: 10),
                    pw.Row(children: [pw.Text('No. Kad Pengenalan.: ')]),
                    pw.SizedBox(height: 20),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 500,
                            child: pw.Text(
                              'Saya memperakui makluman di atas telah diterangkan kepada pesakit/ ibu bapa/ penjaga/ suami/ isteri/ saudara terdekat yang tanda tangannya tertera di atas. Pada hemah saya penama yang dirujuk telah memahami kandungan borang ini dan telah bersetuju untuk menerima pemindahan darah atau komponen darah secara sukarela.',
                              textAlign: pw.TextAlign.justify,
                              // overflow: pw.TextOverflow.span
                            ),
                          ),
                        ]),
                    pw.SizedBox(height: 25),
                    pw.Text('...........................'),
                    pw.Text('Tanda tangan saksi'),
                    pw.SizedBox(height: 5),
                    pw.Text('Nama saksi:'),
                    pw.SizedBox(height: 5),
                    pw.Text('No. Kad Pengenalan saksi:'),
                    pw.SizedBox(height: 15),
                    pw.Text('* potong yang tidak berkaitan'),
                    pw.Text('** jika perlu'),
                  ]);
            })
        // index: 0
        );

    pdf.addPage(pw.Page(
            pageFormat: pf.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.SizedBox(height: 8),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                color: PdfColors.black,
                                width: 1,
                              )),
                              child: pw.Text('HSAJB/O&G-60/VER1.0/2018')),
                        ]),
                    pw.SizedBox(height: 10),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('EMERGENCY LSCS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold, fontSize: 22))
                        ]),
                    pw.SizedBox(height: 15),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                              width: 200,
                              child: pw.Text('ORDERED BY',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 15))),
                          pw.Container(
                              width: 250,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(width: 2))),
                              child: pw.Text(': ${spName.text.capitalize}',
                                  style: pw.TextStyle(
                                      // decoration: pw.TextDecoration.underline,
                                      // decorationStyle:
                                      //     pw.TextDecorationStyle.solid,
                                      fontSize: 12))),
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                              width: 200,
                              child: pw.Text('DATE / TIME OF BOOKING',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 15))),
                          pw.Container(
                              width: 250,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(width: 2))),
                              child: pw.Text(
                                  ': ${DateFormat("dd/MM/yyyy kk:mm").format(DateTime.now())}',
                                  style: pw.TextStyle(
                                      // decoration: pw.TextDecoration.underline,
                                      // decorationStyle:
                                      //     pw.TextDecorationStyle.solid,
                                      fontSize: 12))),
                        ]),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                              width: 200,
                              child: pw.Text('INDICATION',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 15))),
                          pw.Container(
                              width: 250,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                      bottom: pw.BorderSide(width: 2))),
                              child: pw.Text(': ${indication.text.capitalize}',
                                  style: pw.TextStyle(fontSize: 12))),
                        ]),
                    pw.SizedBox(height: 40),
                    pw.Row(children: [
                      pw.Text('PROBLEMS PRIOR TO LSCS',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 15))
                    ]),
                    pw.Container(
                        child: pw.Column(
                            children: comorbidList.map((icn) {
                      cmInt += 1;
                      return pw.Row(children: [
                        pw.Text(cmInt.toString() + '. '),
                        pw.Container(
                            height: 20,
                            width: 440,
                            decoration: pw.BoxDecoration(
                                border:
                                    pw.Border(bottom: pw.BorderSide(width: 2))),
                            child:
                                pw.Text('', style: pw.TextStyle(fontSize: 15))),
                      ]);
                    }).toList())),
                    pw.SizedBox(height: 30),
                    pw.Text('PROBLEM ANTICIPATED DURING SURGERY',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 15)),
                    pw.Container(
                        width: 440,
                        height: 22,
                        padding: pw.EdgeInsets.only(top: 7),
                        decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 2))),
                        child: pw.Text(
                            '  Risk of bleeding requiring blood tranfusion',
                            style: pw.TextStyle(fontSize: 12))),
                    pw.Container(
                        width: 440,
                        height: 22,
                        padding: pw.EdgeInsets.only(top: 7),
                        decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 2))),
                        child: pw.Text(
                            '  Risk of injury to bowel, bladder and ureter',
                            style: pw.TextStyle(fontSize: 12))),
                    pw.Container(
                        width: 440,
                        height: 22,
                        padding: pw.EdgeInsets.only(top: 7),
                        decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 2))),
                        child: pw.Text('  Risk of injury to fetus',
                            style: pw.TextStyle(fontSize: 12))),
                    pw.Container(
                        width: 440,
                        height: 22,
                        padding: pw.EdgeInsets.only(top: 7),
                        decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 2))),
                        child: pw.Text('  Risk of anaesthesia',
                            style: pw.TextStyle(fontSize: 12))),
                    pw.Container(
                        width: 440,
                        height: 22,
                        padding: pw.EdgeInsets.only(top: 7),
                        decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 2))),
                        child: pw.Text('  Risk of venous thromboembolism',
                            style: pw.TextStyle(fontSize: 12))),
                    pw.SizedBox(height: 25),
                    pw.Row(children: [
                      pw.Container(
                        width: 300,
                        child: pw.Text('SURGEON',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 15)),
                      ),
                      pw.Text('WITNESSED BY',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 15))
                    ]),
                    pw.SizedBox(height: 20),
                    pw.Row(children: [
                      pw.Container(
                        width: 300,
                        child: pw.Text('.................................',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 15)),
                      ),
                      pw.Text('.................................',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 15))
                    ]),
                    pw.SizedBox(height: 10),
                    pw.Row(children: [
                      pw.Container(
                        width: 300,
                        child: pw.Text('NAME',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 15)),
                      ),
                      pw.Text('NAME',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 15))
                    ]),
                    pw.Row(children: [
                      pw.Container(
                        width: 300,
                        child: pw.Text('DATE / TIME',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 15)),
                      ),
                      pw.Text('DATE / TIME',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 15))
                    ]),
                  ]);
            })
        // index: 0
        );
  }

  void initDownloader() async {
    profileImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/msia_logo.png'))
          .buffer
          .asUint8List(),
    );
    // theme = await _myPageTheme();
    if (!initDownload) {
      initDownload = true;
      TextStyle();
    }
  }

  Future<nat.PdfController> createDoc() async {
    pdf.addPage(
        pw.Page(
            pageFormat: pf.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: <pw.Widget>[
                      pw.Text('DISCHARGE NOTE'),
                      pw.SizedBox(height: 10),
                      pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU'),
                      pw.SizedBox(height: 20),
                      pw.Row(children: [
                        pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                              color: PdfColors.black,
                              width: 1,
                            )),
                            width: 160,
                            height: 100,
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('1. NAME'),
                                  pw.Text('Chao Tao Xin'),
                                ])),
                        pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                              color: PdfColors.black,
                              width: 1,
                            )),
                            width: 100,
                            height: 100,
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('2. R/N'),
                                  pw.Text('2015295'),
                                ])),
                        pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                              color: PdfColors.black,
                              width: 1,
                            )),
                            width: 100,
                            height: 100,
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('3. MRN'),
                                  // pw.Text('2015295'),
                                ])),
                        pw.Container(
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                              color: PdfColors.black,
                              width: 1,
                            )),
                            width: 120,
                            height: 100,
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('4. I/C NO.'),
                                  pw.Text('960414-04-1414'),
                                ])),
                      ])
                    ]),
              ); // Center
            }),
        index: 0);
    pdf.addPage(
        pw.Page(
            pageFormat: pf.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Column(children: <pw.Widget>[
                  pw.Text('DISCHARGE NOTE'),
                  pw.SizedBox(height: 10),
                  pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU'),
                  pw.SizedBox(height: 20),
                  pw.Row(children: [
                    pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                          color: PdfColors.black,
                          width: 1,
                        )),
                        width: 160,
                        height: 100,
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('1. NAME'),
                              pw.Text('Chao Tao Xin'),
                            ])),
                    pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                          color: PdfColors.black,
                          width: 1,
                        )),
                        width: 100,
                        height: 100,
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('2. R/N'),
                              pw.Text('2015295'),
                            ])),
                    pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                          color: PdfColors.black,
                          width: 1,
                        )),
                        width: 100,
                        height: 100,
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('3. MRN'),
                              // pw.Text('2015295'),
                            ])),
                    pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                          color: PdfColors.black,
                          width: 1,
                        )),
                        width: 120,
                        height: 100,
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('4. I/C NO.'),
                              pw.Text('960414-04-1414'),
                            ])),
                  ])
                ]),
              );
            }),
        index: 1);
    pdfController = nat.PdfController(
      document: nat.PdfDocument.openData(await pdf.save()),
    );
    return pdfController;
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
              child: Text('Print'),
              onPressed: () async {
                await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdf.save());
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
