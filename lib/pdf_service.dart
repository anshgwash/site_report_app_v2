import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class PdfService {
  Future<String> generateSiteReportPdf(Map<String, dynamic> formData) async {
    final pdf = pw.Document();

    // ... (existing code remains the same)

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (context) {
          return [
            // ... (existing headers and tables)

            // Checklist header
            pw.Header(
              level: 2,
              child: pw.Text(
                'Following points were observed during site visit',
              ),
            ),

            // Main checklist table
            pw.Table.fromTextArray(
              context: context,
              columnWidths: {
                0: pw.FractionColumnWidth(0.05),
                1: pw.FractionColumnWidth(0.5),
                2: pw.FractionColumnWidth(0.05),
                3: pw.FractionColumnWidth(0.4),
              },
              data: _buildChecklistData(formData),
            ),

            // ... (rest of your code building images, etc.)
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/site_report.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  // UPDATED HELPER METHOD
  // TODO: change font so that emoji works in PDF
  String _getYesNo(dynamic value) {
    if (value == 'Yes') return '✓';
    if (value == 'No') return 'x';
    return '-'; // or any icon you prefer for "N/A"
  }

  // UPDATED CHECKLIST DATA WITH RENAMED COLUMN (OPTIONAL)
  List<List<String>> _buildChecklistData(Map<String, dynamic> formData) {
    return <List<String>>[
      <String>[
        'Sr No',
        'Description of Items',
        'Status',
        'Remarks',
      ], // changed "Y/N" -> "Status"
      // 1. Drawing on site audit
      <String>['1', 'Drawings on site- Audit', '-', '-'],
      <String>[
        'A',
        'No superseded drawings on site/correct drawings being referred',
        _getYesNo(formData['correct_drawing_yn']),
        '',
      ],
      // ... rest of your checklist rows remain the same,
      // except they now pick up the new emojis from _getYesNo
    ];
  }

  // ... (rest of your code)
}
