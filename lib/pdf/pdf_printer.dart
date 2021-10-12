import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rss/model/item.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class PDFPrinter {
  Future<void> saveAndOpen(
    BuildContext context,
    Item item,
  ) async {
    final pdf = await _generatePDF(
      context,
      item,
    );
    final appDocDirectory = await getExternalStorageDirectory();
    final file = File(appDocDirectory.path + '/example.pdf');
    file.writeAsBytesSync(await pdf.save());
    await OpenFile.open(file.path);
  }

  Future<void> printPDF(
    BuildContext context,
    Item item,
  ) async {
    final pdf = await _generatePDF(
      context,
      item,
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<pw.Document> _generatePDF(
    BuildContext context,
    Item item,
  ) async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }

    final pdf = pw.Document();
    var imageBytes = await _getImageData(item);
    var ttf = await _loadFont();

    pdf.addPage(pw.Page(
      pageFormat:
          PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      build: (context) => pw.Padding(
        padding: pw.EdgeInsets.all(8.0),
        child: pw.Column(
          children: [
            if (imageBytes != null)
              pw.Container(
                decoration: pw.BoxDecoration(
                  boxShadow: [
                    pw.BoxShadow(
                      color: PdfColors.black,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: pw.Image(
                  pw.ImageProxy(
                    PdfImage.jpeg(
                      pdf.document,
                      image: imageBytes,
                    ),
                  ),
                ),
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                item.title,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 16.0,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Container(
              width: double.infinity,
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(4.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      item.pubDate,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(item.description,
                    style: pw.TextStyle(
                      font: ttf,
                    )),
              ),
            ),
          ],
        ),
      ),
    ));

    return pdf;
  }

  Future<pw.Font> _loadFont() async {
    final ttfBundle = await rootBundle.load('fonts/open-sans.ttf');
    return pw.Font.ttf(ttfBundle);
  }

  Future _getImageData(Item item) async {
    var imageBytes;
    if (item.enclosureUrl.contains('.jpg')) {
      var response = await http.get(Uri.parse(item.enclosureUrl));
      imageBytes = response.bodyBytes;
    }
    return imageBytes;
  }
}
