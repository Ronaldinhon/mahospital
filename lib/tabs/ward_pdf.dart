import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/page_format.dart' as pf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controllers/entry_chart_controller.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:permission_handler/permission_handler.dart';

class WardPdf extends StatefulWidget {
  // final Function(File file, BuildContext context) upLevelPdf;
  WardPdf();
  @override
  _WardPdfState createState() => _WardPdfState();
}

class _WardPdfState extends State<WardPdf> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  final pdf1 = pw.Document();
  List<BedModel> sample = [];
  List<String> data = [];
  List<String> showData = [];
  String holder = '';
  Base64Codec st = Base64Codec();
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  @override
  void initState() {
    // createDoc();
    super.initState();
    sample..addAll(currentWPLC.currentBML);
    for (BedModel bm in sample) {
      data.add(bm.name);
      data.add(!bm.ptInitialised ? 'No Patient' : bm.wardPtModel.ptDetails());
      if (!bm.ptInitialised) {
        data.add(
            '_____________________________________________________________________________________________\n');
      } else {
        data.add('Diag:');
        data.addAll(bm.wardPtModel.curDiag.split('\n'));
        data.add('Plan:');
        data.addAll(bm.wardPtModel.curPlan.split('\n'));
        data.add(
            '_____________________________________________________________________________________________\n');
      }
    }
    separatePages();
    showData.asMap().forEach((index, value) => addPdfPgFunc(index));
    pdf1.addPage(pw.MultiPage(
        maxPages: 50,
        pageFormat: pf.PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Text('tell me whyyyyyy ${context.pageNumber}');
        },
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex("#000000")),
                children: [
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text('slaskjd\nlasdj\nlaksdjl\nalskdj')),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(7),
                        child: pw.Text(
                            'slasdljlfksjlkfjsskjd\nladfsfsfsdsdj\nlhkhjhaksdjl\nalaskjhjhaslskdjfslkdjfsdlkjsdfslkfsldkfjskdjsks skhjfskdhf sdkfhksfhsdkjh sdjfhsdkfh ssjhfsdh fksdjh sdfkhsdfkhdskfh sdkfjhskfhkdsjhf sdkfjhskfhdsfh skfsdhfk sdkfjsh skdfhskhskjdhfkjsdhfksdhhsdkfs sdkfjhshfskjhfkdhfhskjhfskhfskh sdkfhskhfkshksdhfs sdkfhhksdhfkjsf'))
                  ]),
                ],
                columnWidths: {
                  0: pw.FractionColumnWidth(1),
                  1: pw.FractionColumnWidth(3)
                }
                // ecController.asdljk.map((Pt value) {
                //   return pw.TableRow(children: [
                //     pw.Container(
                //         width: 15,
                //         padding: pw.EdgeInsets.all(4.0),
                //         child: pw.Text(stringToBase64.decode(
                //             st.normalize(stringToBase64.encode(value.hNum))))),
                //     pw.Container(
                //         width: 30,
                //         padding: pw.EdgeInsets.all(4.0),
                //         child: pw.Text(stringToBase64.decode(
                //             st.normalize(stringToBase64.encode(value.name))))),
                //     pw.Container(
                //         width: 30,
                //         padding: pw.EdgeInsets.all(4.0),
                //         child: pw.Text(stringToBase64.decode(
                //             st.normalize(stringToBase64.encode(value.ic))))),
                //     pw.Container(
                //         width: 70,
                //         padding: pw.EdgeInsets.all(4.0),
                //         child: pw.Text(stringToBase64.decode(
                //             st.normalize(stringToBase64.encode(value.add))))),
                //     pw.Container(
                //         width: 30,
                //         padding: pw.EdgeInsets.all(4.0),
                //         child: pw.Text(stringToBase64.decode(
                //             st.normalize(stringToBase64.encode(value.phone))))),
                //     // pw.Container(
                //     //     width: 30,
                //     //     padding: pw.EdgeInsets.all(4.0),
                //     //     child: pw.Column(
                //     //         crossAxisAlignment: pw.CrossAxisAlignment.start,
                //     //         children: [
                //     //           pw.Text(
                //     //               'asaslkdjlksdsdlkjlskjslkjdlkjsdlksljdsdljslkdslkdslkdllksldslkdlkdsklsdlklksjlkjsdlkjslkdjsldkjsksdlkjlsdkjlskjlksdjlksdjlksjlkjsdlkjsdlksjdlksdjlslkjldkjslkjsk')
                //     //         ])),
                //   ]);
                // }).toList()
                ),
          ];
        }));
  }

  void addPdfPgFunc(int i) {
    pdf.addPage(pw.Page(
        pageFormat: pf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: <pw.Widget>[
            pw.Header(
                level: 0,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Text('${currentWPLC.cwm.value.shortName} Patient List',
                          textScaleFactor: 1),
                      pw.Text('Page ${i + 1}')
                      // pw.PdfLogo()
                    ])),
            pw.Container(
                width: 480,
                height: 690,
                // decoration: pw.BoxDecoration(
                //   border: pw.Border.all(
                //     width: 1,
                //   ),
                // ),
                child: pw.Text(showData[i],
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(fontSize: 12))),
          ]);
        }));
  }

  void separatePages() {
    // diags = currentWPLC.cwpm.value.curDiag.split('\n');
    // print(diags);
    // var showPageString = '';
    while (data.length != 0) {
      holder = data.removeAt(0);
      if (getHeight(holder, 460) < 688) {
        while (getHeight(holder, 460) < 688) {
          if (data.isEmpty) break;
          String tempLine = data.removeAt(0);
          String tempDiag = holder + '\n' + tempLine;
          if (getHeight(tempDiag, 460) > 688) {
            data.insert(0, tempLine);
            break;
          }
          holder = tempDiag;
        }
        showData.add(holder);
        holder = '';
      } else {
        String excess = '';
        while (getHeight(holder, 460) > 688) {
          var lastIndex = holder.lastIndexOf(" ");
          if (!holder.contains(' ')) lastIndex = holder.length - 2;
          var just = holder.substring(lastIndex);
          holder = holder.substring(0, lastIndex);
          excess = just + excess;
        }
        data.insert(0, excess);
        showData.add(holder);
        holder = '';
      }
    }
  }

  double getHeight(String sp, double width) {
    TextPainter textPainter = TextPainter()
      ..text = TextSpan(
          text: sp,
          style: TextStyle(
              fontSize:
                  11)) // i must say this is kinda weird but it works so fuck it
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: width);
    return textPainter.height;
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
              child: Text('Back'),
              onPressed: () => ecController.printingSum.value = false,
              // onPressed: () async {
              //   await Printing.layoutPdf(
              //       onLayout: (PdfPageFormat format) async => pdf.save());
              // },
            ),
          ),
        ),
        Expanded(
          child: PdfPreview(
            build: (format) => pdf1.save(),
          ),
        )
      ],
    );
  }
}

// pdf.addPage(
//     pw.MultiPage(
//         pageFormat: pf.PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return
//               // pw.Center(
//               //   child:
//               // pw.Column(children:
//               <pw.Widget>[
//             pw.Header(
//               level: 0,
//               // title: 'Portable Document Format',
//               child:
//                   // pw.Row(
//                   //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   //     children: <pw.Widget>[
//                   pw.Text('${currentWPLC.cwm.value.shortName} Patient List',
//                       textScaleFactor: 2),
//               //   pw.PdfLogo()
//               // ])
//             ),
//             pw.Table(
//                 border: pw.TableBorder.all(),
//                 children: sample.map((bm) {
//                   return pw.TableRow(children: [
//                     pw.Container(
//                         width: 50,
//                         // decoration: pw.BoxDecoration(
//                         //   border: pw.Border.all(
//                         //     width: 1,
//                         //   ),
//                         // ),
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text(bm.name),
//                               pw.SizedBox(height: 4),
//                               pw.Text(!bm.ptInitialised
//                                   ? 'No Patient'
//                                   : bm.wardPtModel.ptDetails())
//                             ])),
//                     pw.Container(
//                         width: 150,
//                         // decoration: pw.BoxDecoration(
//                         //   border: pw.Border.all(
//                         //     width: 1,
//                         //   ),
//                         // ),
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text(
//                                 !bm.ptInitialised
//                                     ? '-'
//                                     : 'Dx: \n' +
//                                         currentWPLC.cpCurDiag.text +
//                                         '\n \n Plan: \n' +
//                                         currentWPLC.cpCurPlan.text,
//                                 // !bm.wardPtModel.rerIni
//                                 //     ? 'No entry yet'
//                                 //     : bm.wardPtModel.name
//                                 //         .toString()
//                               )
//                             ]))
//                   ]);
//                 }).toList())
//           ];
//         }),
//     index: 0);

// void initDownloader() async {
//   if (!initDownload) {
//     // await FlutterDownloader.initialize(debug: true);
//     initDownload = true;
//   }
// }

// Future<nat.PdfController> createDoc() async {
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
//             ); // Center
//           }),
//       index: 1);
//   // final tempPath = await getTemporaryDirectory();
//   // pdfFile = File("${tempPath.path}/example.pdf");
//   // final file = File("example.pdf");
//   // await file.writeAsBytes(await pdf.save());
//   // doc = await PDFDocument.fromFile(pdfFile);
//   // widget.upLevelPdf(pdfFile, context);
//   pdfController = nat.PdfController(
//     document: nat.PdfDocument.openData(await pdf.save()),
//   );
//   return pdfController;
// }

// class PdfShow extends StatefulWidget {
//   // final Function(File file, BuildContext context) upLevelPdf;
//   PdfShow();
//   @override
//   _PdfShowState createState() => _PdfShowState();
// }

// class _PdfShowState extends State<PdfShow> {
//   late File pdfFile;
//   late nat.PdfController pdfController;
//   bool initDownload = false;
//   final pdf = pw.Document();

//   @override
//   void initState() {
//     // TODO: implement initState
//     // createDoc();
//     initDownloader();
//     super.initState();
//   }

//   void initDownloader() async {
//     if (!initDownload) {
//       // await FlutterDownloader.initialize(debug: true);
//       initDownload = true;
//     }
//   }

//   Future<nat.PdfController> createDoc() async {
//     pdf.addPage(
//         pw.Page(
//             pageFormat: pf.PdfPageFormat.a4,
//             build: (pw.Context context) {
//               return pw.Center(
//                 child: pw.Column(children: <pw.Widget>[
//                   pw.Text('DISCHARGE NOTE'),
//                   pw.SizedBox(height: 10),
//                   pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU'),
//                   pw.SizedBox(height: 20),
//                   pw.Row(children: [
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 160,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('1. NAME'),
//                               pw.Text('Chao Tao Xin'),
//                             ])),
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 100,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('2. R/N'),
//                               pw.Text('2015295'),
//                             ])),
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 100,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('3. MRN'),
//                               // pw.Text('2015295'),
//                             ])),
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 120,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('4. I/C NO.'),
//                               pw.Text('960414-04-1414'),
//                             ])),
//                   ])
//                 ]),
//               ); // Center
//             }),
//         index: 0);
//     pdf.addPage(
//         pw.Page(
//             pageFormat: pf.PdfPageFormat.a4,
//             build: (pw.Context context) {
//               return pw.Center(
//                 child: pw.Column(children: <pw.Widget>[
//                   pw.Text('DISCHARGE NOTE'),
//                   pw.SizedBox(height: 10),
//                   pw.Text('HOSPITAL SULTANAH AMINAH, JOHOR BAHRU'),
//                   pw.SizedBox(height: 20),
//                   pw.Row(children: [
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 160,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('1. NAME'),
//                               pw.Text('Chao Tao Xin'),
//                             ])),
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 100,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('2. R/N'),
//                               pw.Text('2015295'),
//                             ])),
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 100,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('3. MRN'),
//                               // pw.Text('2015295'),
//                             ])),
//                     pw.Container(
//                         decoration: pw.BoxDecoration(
//                             border: pw.Border.all(
//                           color: PdfColors.black,
//                           width: 1,
//                         )),
//                         width: 120,
//                         height: 100,
//                         padding: pw.EdgeInsets.all(8.0),
//                         child: pw.Column(
//                             crossAxisAlignment: pw.CrossAxisAlignment.start,
//                             children: [
//                               pw.Text('4. I/C NO.'),
//                               pw.Text('960414-04-1414'),
//                             ])),
//                   ])
//                 ]),
//               ); // Center
//             }),
//         index: 1);
//     // final tempPath = await getTemporaryDirectory();
//     // pdfFile = File("${tempPath.path}/example.pdf");
//     // final file = File("example.pdf");
//     // await file.writeAsBytes(await pdf.save());
//     // doc = await PDFDocument.fromFile(pdfFile);
//     // widget.upLevelPdf(pdfFile, context);
//     pdfController = nat.PdfController(
//       document: nat.PdfDocument.openData(await pdf.save()),
//     );
//     return pdfController;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<nat.PdfController>(
//       future: createDoc(),
//       builder:
//           (BuildContext context, AsyncSnapshot<nat.PdfController> snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return nat.PdfView(
//             controller: snapshot.data!,
//           );
//         } else {
//           return Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }

// SingleChildScrollView(
//   child: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       ElevatedButton(
//         child: Text("Start Downloading"),
//         onPressed: () async {
//           final status = await Permission.storage.request();

//           if (status.isGranted) {
//             final externalDir = await getExternalStorageDirectory();

//             final id = await FlutterDownloader.enqueue(
//               url: pdfFile.path,
//               savedDir: externalDir.path,
//               fileName: "downloadPDF",
//               showNotification: true,
//               openFileFromNotification: true,
//             );
//           } else {
//             print("Permission deined");
//           }
//         },
//       ),
