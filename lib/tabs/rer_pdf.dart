import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/page_format.dart' as pf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:permission_handler/permission_handler.dart';

class RerPdf extends StatefulWidget {
  // final Function(File file, BuildContext context) upLevelPdf;
  RerPdf();
  @override
  _RerPdfState createState() => _RerPdfState();
}

class _RerPdfState extends State<RerPdf> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();

  @override
  void initState() {
    // TODO: implement initState
    // createDoc();
    initDownloader();
    super.initState();
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
              ); // Center
            }),
        index: 0);
  }

  void initDownloader() async {
    if (!initDownload) {
      // await FlutterDownloader.initialize(debug: true);
      initDownload = true;
    }
  }

  Future<nat.PdfController> createDoc() async {
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
              ); // Center
            }),
        index: 1);
    // final tempPath = await getTemporaryDirectory();
    // pdfFile = File("${tempPath.path}/example.pdf");
    // final file = File("example.pdf");
    // await file.writeAsBytes(await pdf.save());
    // doc = await PDFDocument.fromFile(pdfFile);
    // widget.upLevelPdf(pdfFile, context);
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

class PdfShow extends StatefulWidget {
  // final Function(File file, BuildContext context) upLevelPdf;
  PdfShow();
  @override
  _PdfShowState createState() => _PdfShowState();
}

class _PdfShowState extends State<PdfShow> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();

  @override
  void initState() {
    // TODO: implement initState
    // createDoc();
    initDownloader();
    super.initState();
  }

  void initDownloader() async {
    if (!initDownload) {
      // await FlutterDownloader.initialize(debug: true);
      initDownload = true;
    }
  }

  Future<nat.PdfController> createDoc() async {
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
              ); // Center
            }),
        index: 1);
    // final tempPath = await getTemporaryDirectory();
    // pdfFile = File("${tempPath.path}/example.pdf");
    // final file = File("example.pdf");
    // await file.writeAsBytes(await pdf.save());
    // doc = await PDFDocument.fromFile(pdfFile);
    // widget.upLevelPdf(pdfFile, context);
    pdfController = nat.PdfController(
      document: nat.PdfDocument.openData(await pdf.save()),
    );
    return pdfController;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<nat.PdfController>(
      future: createDoc(),
      builder:
          (BuildContext context, AsyncSnapshot<nat.PdfController> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return nat.PdfView(
            controller: snapshot.data!,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

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
