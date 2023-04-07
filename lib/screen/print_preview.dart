import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintPreview extends StatelessWidget {
  final pw.Document pdf;

  const PrintPreview({Key? key, required this.pdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (format) => pdf.save(),
    );
  }
}
