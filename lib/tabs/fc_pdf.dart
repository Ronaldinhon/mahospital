import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mahospital/constants/controllers.dart';
import 'package:mahospital/models/bed_model.dart';
import 'package:native_pdf_view/native_pdf_view.dart' as nat;
import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/page_format.dart' as pf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import 'package:quiver/iterables.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/asymmetric/api.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:permission_handler/permission_handler.dart';

class FcPdf extends StatefulWidget {
  FcPdf();
  @override
  FcPdfState createState() => FcPdfState();
}

class FcPdfState extends State<FcPdf> {
  late File pdfFile;
  late nat.PdfController pdfController;
  bool initDownload = false;
  final pdf = pw.Document();
  // List<BedModel> sample = [];
  List<String> data = [];
  List<String> showData = [];
  String holder = '';
  Iterable<List> headerDatesInt = [];
  Map modifiedIterable = {};

  List<String> bloodParam = [
    'Hb',
    'Hct',
    'MCV',
    'MCH',
    'Plt',
    'Twc',
    'PMN',
    'Lymph',
    'Eos',
    'Mono',
    'Urea',
    'Creat',
    'Na',
    'K',
    'Cl',
    'Ca',
    'Phos',
    'Mg',
    'TBil',
    'Dir',
    'Indir',
    'Pro',
    'Alb',
    'Glob',
    'ALT',
    'ALP',
    'CK',
    'AST',
    'LDH',
    'PT',
    'APTT',
    'INR',
    'ESR',
    'CRP',
    'T4',
    'TSH',
    'ferri',
    'iron',
    'UIBC',
    'TIBC',
    'Tr.Sat',
  ];

  @override
  void initState() {
    // createDoc();
    super.initState();
    // sample..addAll(currentWPLC.currentBML);
    if (ecController.numberOfDays != 0) {
      headerDatesInt = partition(ecController.orderedDateTime, 11);
      ecController.masterMap.forEach((k, v) {
        modifiedIterable[k] = partition(v, 11);
      });
    }
    List<int> pgList = List.generate(headerDatesInt.length, (i) => i);
    for (int pop in pgList) {
      addPdfPgFunc(pop);
    }
    callAsyncFunc();
  }

  void callAsyncFunc() async {
    keyPair = await getKeyPair();
    // RSAPrivateKey privateKey = keyPair.privateKey as RSAPrivateKey;
    var help = RsaKeyHelper();
    var pr =
        help.encodePrivateKeyToPemPKCS1(keyPair.privateKey as RSAPrivateKey);
    var pub = help.encodePublicKeyToPemPKCS1(keyPair.publicKey as RSAPublicKey);
    var enc = encrypt('Stanley baby', help.parsePublicKeyFromPem(pub));
    var dec = decrypt(enc, help.parsePrivateKeyFromPem(pr));
    print(enc);
    print(dec);
  }

//to store the KeyPair once we get data from our future
  late crypto.AsymmetricKeyPair keyPair;
  late String privKey;
  late String pubKey;

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() async {
    var helper = RsaKeyHelper();
    return await helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  List<pw.Widget> _getTitleWidget(int ii) {
    List<pw.Container> header = [];
    header.add(pw.Container(
      width: 40,
      height: 40,
      decoration: pw.BoxDecoration(
          border: pw.Border.all(
        color: PdfColors.black,
        width: 1,
      )),
    ));
    // print(ii);
    if (ecController.numberOfDays != 0)
      headerDatesInt.toList()[ii].asMap().forEach((intt, dt) {
        int tim = int.parse(dt);
        var timi = DateTime.fromMillisecondsSinceEpoch(tim);
        header.add(pw.Container(
            padding: pw.EdgeInsets.only(left: 2, top: 2),
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            )),
            child: pw.Column(children: [
              pw.Text(intl.DateFormat('dd/MM').format(timi),
                  style: pw.TextStyle(fontSize: 9)),
              pw.Text(intl.DateFormat('yyyy').format(timi),
                  style: pw.TextStyle(fontSize: 9)),
              pw.Text(intl.DateFormat('kk:mm').format(timi),
                  style: pw.TextStyle(fontSize: 9)),
            ])));
      });
    return header;
  }

  List<pw.Widget> buildLines(int ii) {
    List<pw.Widget> lines = [];
    for (String bp in ecController.bloodParam) {
      List<pw.Widget> innerLines = [];
      innerLines.add(pw.Container(
        child: pw.Center(
            child: pw.Text(bp,
                overflow: pw.TextOverflow.clip,
                style: pw.TextStyle(fontSize: 9))),
        width: 40,
        height: 16,
        decoration: pw.BoxDecoration(
            border: pw.Border.all(
          color: PdfColors.black,
          width: 1,
        )),
      ));
      // print(ii);
      for (String lulu in modifiedIterable[bp].toList()[ii]!) {
        innerLines.add(pw.Container(
          child: pw.Center(
              child: pw.Text(lulu,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(fontSize: 9))),
          width: 40,
          height: 16,
          decoration: pw.BoxDecoration(
              border: pw.Border.all(
            color: PdfColors.red,
            width: 1,
          )),
        ));
      }
      pw.Row roll = pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          // crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: innerLines);
      lines.add(roll);
    }
    // List n36 = List.generate(41, (i) => i); // max 41 - nice for now
    // for (var i in n36) {
    //   lines.add(pw.Row(children: [
    //     pw.Container(
    //         padding: pw.EdgeInsets.only(left: 2, top: 2),
    //         width: 411,
    //         height: 16,
    //         decoration: pw.BoxDecoration(
    //             border: pw.Border.all(
    //           color: PdfColors.black,
    //           width: 1,
    //         )),
    //         child: pw.Text(bloodParam[i],
    //             overflow: pw.TextOverflow.clip,
    //             style: pw.TextStyle(fontSize: 10)))
    //   ]));
    // }
    return lines;
  }

  void addPdfPgFunc(int i) {
    pdf.addPage(pw.Page(
        pageFormat: pf.PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Header(
                    level: 0,
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: <pw.Widget>[
                          pw.Text('Name: Ali  Ic: 123456', textScaleFactor: 1),
                          pw.Text('Page ${i + 1}')
                          // pw.PdfLogo()
                        ])),
                // makeHeader(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: _getTitleWidget(i)),
                ...buildLines(i)
              ]);
        }));
    // print('i=' + i.toString());
    // print('l=' + headerDatesInt.length.toString());
    // if (i < headerDatesInt.length) addPdfPgFunc(++i);
  }

  pw.Row makeHeader() {
    List n10 = List.generate(13, (i) => i);
    List<pw.Container> header = [];
    for (var i in n10) {
      if (i != 0) {
        header.add(pw.Container(
            padding: pw.EdgeInsets.only(left: 2, top: 2),
            width: 37,
            height: 40,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            )),
            child: pw.Column(children: [
              pw.Text('02/02', style: pw.TextStyle(fontSize: 10)),
              pw.Text('2022', style: pw.TextStyle(fontSize: 10)),
              pw.Text('05:00', style: pw.TextStyle(fontSize: 10)),
            ])));
      } else {
        header.add(pw.Container(
          width: 35,
          height: 40,
          decoration: pw.BoxDecoration(
              border: pw.Border.all(
            color: PdfColors.black,
            width: 1,
          )),
        ));
      }
    }
    return pw.Row(children: header);
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
              onPressed: () => ecController.printingFC.value = false,
              // onPressed: () async {
              //   await Printing.layoutPdf(
              //       onLayout: (PdfPageFormat format) async => pdf.save());
              // },
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
