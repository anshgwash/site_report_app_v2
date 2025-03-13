import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class PdfService {
  Future<void> generateSiteReportPdf(
    Map<String, dynamic> formData, [
    Map<String, dynamic>? imageData,
  ]) async {
    // Initialize imageData if not provided
    final Map<String, dynamic> safeImageData = imageData ?? {};

    final pdf = pw.Document();

    // Image handling
    List<pw.ImageProvider?> imagesList = List.filled(10, null);
    List<pw.ImageProvider?> elevImages = List.filled(4, null);

    // Logo image
    pw.ImageProvider? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      print('Logo image not found: $e');
    }

    // Load elevation images
    for (var i = 1; i <= 4; i++) {
      print('Checking elev$i: ${safeImageData['elev$i']}');
      if (safeImageData['elev$i'] != null &&
          safeImageData['elev$i'].toString().isNotEmpty) {
        print('Elevation $i image is not empty');
        try {
          String imgFiles = safeImageData['elev$i'].toString();
          // Check if additional parsing is needed
          String filePath = imgFiles;
          if (imgFiles.contains('[') && imgFiles.contains(']')) {
            // Handle parsing similar to original code if needed
            filePath = imgFiles.substring(
              imgFiles.indexOf('[') + 1,
              imgFiles.lastIndexOf(']'),
            );
          }

          print('Loading elevation image from: $filePath');
          final file = File(filePath);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            elevImages[i - 1] = pw.MemoryImage(bytes);
            print('Successfully loaded elevation $i image');
          } else {
            print('File not found: $filePath');
          }
        } catch (e) {
          print('Error loading elevation image $i: $e');
        }
      } else {
        print('No image path found for elev$i');
      }
    }

    // Load other images
    for (var i = 1; i <= 10; i++) {
      print('Checking img$i: ${safeImageData['img$i']}');
      if (safeImageData['img$i'] != null &&
          safeImageData['img$i'].toString().isNotEmpty) {
        print('Image $i is not empty');
        try {
          String imgFiles = safeImageData['img$i'].toString();
          // Check if additional parsing is needed
          String filePath = imgFiles;
          if (imgFiles.contains('[') && imgFiles.contains(']')) {
            // Handle parsing similar to original code if needed
            filePath = imgFiles.substring(
              imgFiles.indexOf('[') + 1,
              imgFiles.lastIndexOf(']'),
            );
          }

          print('Loading image from: $filePath');
          final file = File(filePath);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            imagesList[i - 1] = pw.MemoryImage(bytes);
            print('Successfully loaded image $i');
          } else {
            print('File not found: $filePath');
          }
        } catch (e) {
          print('Error loading image $i: $e');
        }
      } else {
        print('No image path found for img$i');
      }
    }

    // Create PDF document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (context) {
          return [
            // Header with project name and logo
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${formData['projectName'] ?? 'Project'} - (Site Report #${formData['siteReportNo'] ?? 'N/A'})',
                    style: pw.TextStyle(fontSize: 25),
                  ),
                  logoImage != null
                      ? pw.Image(
                        logoImage,
                        fit: pw.BoxFit.contain,
                        height: 74.3,
                        width: 60,
                      )
                      : pw.SizedBox(height: 74.3, width: 60),
                ],
              ),
            ),

            // Project information tables
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Table.fromTextArray(
                    context: context,
                    data: <List<String>>[
                      <String>['Category', 'Value'],
                      <String>[
                        'Subject:',
                        '${formData['typeOfCheck'] ?? 'N/A'}',
                      ],
                      <String>[
                        'Arch Dwg No.:',
                        '${formData['architecturalDwgNo'] ?? 'N/A'}',
                      ],
                      <String>[
                        'Structural Dwg No.:',
                        '${formData['structuralDwgNo'] ?? 'N/A'}',
                      ],
                      <String>[
                        'Section Dwg No.:',
                        '${formData['sectionDwgNo'] ?? 'N/A'}',
                      ],
                      <String>[
                        'Elevation Dwg No.:',
                        '${formData['elevationDwgNo'] ?? 'N/A'}',
                      ],
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Table.fromTextArray(
                    context: context,
                    data: <List<String>>[
                      <String>['Category', 'Value'],
                      <String>[
                        'Slab Level:',
                        '${formData['slabLevel'] ?? 'N/A'}',
                      ],
                      <String>[
                        'Date:',
                        '${DateTime.now().toString().split(' ')[0]}',
                      ],
                      <String>[
                        'Time:',
                        '${DateTime.now().toString().split(' ')[1].substring(0, 5)}',
                      ],
                      <String>[
                        'Site Report No.:',
                        '${formData['siteReportNo'] ?? 'N/A'}',
                      ],
                      <String>[
                        'Site Report By:',
                        '${formData['reportBy'] ?? 'N/A'}',
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Attendance table
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Representing', 'Name and designation'],
                <String>[
                  'Architect',
                  '${formData['representingArchitect'] ?? 'N/A'}',
                ],
                <String>[
                  'Client',
                  '${formData['representingClient'] ?? 'N/A'}',
                ],
                <String>[
                  'Contractor',
                  '${formData['representingContractor'] ?? 'N/A'}',
                ],
              ],
            ),

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

            pw.SizedBox(height: 5),

            // Elevation images
            _buildElevationImage(0, elevImages, safeImageData, 'Front'),
            _buildElevationImage(1, elevImages, safeImageData, 'Rear'),
            _buildElevationImage(2, elevImages, safeImageData, 'Side 1'),
            _buildElevationImage(3, elevImages, safeImageData, 'Side 2'),

            // Other images
            ...List.generate(
              10,
              (i) => _buildOtherImage(i, imagesList, safeImageData),
            ),
          ];
        },
      ),
    );

    // Save and share the PDF
    try {
      final output = await getApplicationDocumentsDirectory();
      final projectName = formData['projectName'] ?? 'Project';
      final reportNo = formData['siteReportNo'] ?? 'NA';
      final fileName = '${projectName}_report$reportNo.pdf';
      final file = File('${output.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      print('PDF saved at: ${file.path}');

      // Share the PDF using the confirmed working method
      try {
        XFile fileXFile = XFile(file.path);
        await Share.shareXFiles([fileXFile], text: 'Site Report PDF');
      } catch (e) {
        print('Error sharing file: $e');
      }
    } catch (e) {
      print('Error saving or sharing PDF: $e');
      rethrow;
    }
  }

  // Helper method to build checklist data
  List<List<String>> _buildChecklistData(Map<String, dynamic> formData) {
    return <List<String>>[
      <String>['Sr No', 'Description of Items', 'Y/N', 'Remarks'],

      // 1. Drawing on site audit
      <String>['1', 'Drawings on site- Audit', '-', '-'],
      <String>[
        'A',
        'No superseded drawings on site/correct drawings being referred',
        _getYesNo(formData['correct_drawing_yn']),
        '',
      ],
      <String>[''],

      // 2. Site Development
      <String>['2', 'Site Development', '-', '-'],
      <String>[
        'A',
        'North of site as per demarcation',
        _getYesNo(formData['north_site_demarcation_yn']),
        '',
      ],
      <String>[
        'B',
        'UG Tanks top slab level marking',
        _getYesNo(formData['ug_tanks_level_yn']),
        '${formData['ug_tanks_level_remarks'] ?? ''}',
      ],
      <String>[
        'C',
        'Site levels marking w.r.t. road level',
        _getYesNo(formData['site_levels_road_yn']),
        '${formData['site_levels_road_remarks'] ?? ''}',
      ],
      <String>[''],

      // 3. Setting out & Center line
      <String>['3', 'Setting out & Centre line checking', '-', '-'],
      <String>[
        'A',
        'Open Offset Dimension',
        _getYesNo(formData['offset_dimension_yn']),
        '${formData['offset_dimension_remarks'] ?? ''}',
      ],
      <String>[
        'B',
        'Column marking as per centre line',
        _getYesNo(formData['column_marking_yn']),
        '${formData['column_marking_remarks'] ?? ''}',
      ],
      <String>[''],

      // 4. Shuttering Check
      <String>['4', 'Shuttering Check', '-', '-'],
      <String>[
        'A',
        'Overall Checking - Supporting lvl, no gaps etc.',
        _getYesNo(formData['shuttering_check_yn']),
        '${formData['shuttering_check_remarks'] ?? ''}',
      ],
      <String>[''],

      // 5. Slab Checking
      <String>['5', 'Slab Checking', '-', '-'],
      <String>[
        'A',
        'Level Of Slab',
        '${formData['level_of_slab'] ?? 'N/A'}',
        '',
      ],
      <String>[
        'B',
        'Cutout for Lift Dimension',
        _getYesNo(formData['slab_item_0_yn']),
        '',
      ],
      <String>[
        'C',
        'Cutout for Plumbing Shaft',
        _getYesNo(formData['slab_item_1_yn']),
        '',
      ],
      <String>[
        'D',
        'Cutout for Electrical',
        _getYesNo(formData['slab_item_2_yn']),
        '',
      ],
      <String>[
        'E',
        'Flower Bed Sunk',
        _getYesNo(formData['slab_item_3_yn']),
        '',
      ],
      <String>['F', 'Toilet Sunk', _getYesNo(formData['slab_item_4_yn']), ''],
      <String>[
        'G',
        'Terrace/Balcony Sunk',
        _getYesNo(formData['slab_item_5_yn']),
        '',
      ],
      <String>[
        'H',
        'Terrace Projection',
        _getYesNo(formData['slab_item_6_yn']),
        '',
      ],
      <String>[
        'I',
        'Basements checking',
        _getYesNo(formData['slab_item_7_yn']),
        '',
      ],
      <String>[
        'J',
        'Size of Column',
        _getYesNo(formData['slab_item_8_yn']),
        '',
      ],
      <String>[
        'K',
        'Alignment of Column',
        _getYesNo(formData['slab_item_9_yn']),
        '',
      ],
      <String>[
        'L',
        'Reduction of Column',
        _getYesNo(formData['slab_item_10_yn']),
        '',
      ],
      <String>[
        'M',
        'Beam - Size and Location',
        _getYesNo(formData['slab_item_11_yn']),
        '',
      ],
      <String>[
        'N',
        'Alignment of Beam Internal',
        _getYesNo(formData['slab_item_12_yn']),
        '',
      ],
      <String>[
        'O',
        'Electrical Sleeves',
        _getYesNo(formData['slab_item_13_yn']),
        '',
      ],
      <String>[
        'P',
        'Plumbing Sleeves',
        _getYesNo(formData['slab_item_14_yn']),
        '',
      ],
      <String>[
        'Q',
        'Hook Fan Location',
        _getYesNo(formData['slab_item_15_yn']),
        '',
      ],
      <String>[
        'R',
        'Chajja projection & alignment w.r.t slab',
        _getYesNo(formData['slab_item_16_yn']),
        '',
      ],
      <String>[
        'S',
        'Other slab projections',
        _getYesNo(formData['slab_item_17_yn']),
        '',
      ],
      <String>[''],

      // 6. Staircase
      <String>['6', 'Staircase', '-', '-'],
      <String>[
        'A',
        'Width of Staircase',
        _getYesNo(formData['staircase_width_yn']),
        '',
      ],
      <String>[
        'B',
        'Dimension of Risers, Treads',
        _getYesNo(formData['staircase_dimensions_yn']),
        '',
      ],
      <String>[
        'C',
        'Mid Landing Level of Staircase',
        _getYesNo(formData['mid_landing_level_yn']),
        '',
      ],
      <String>[
        'D',
        'Hand Railing Details',
        _getYesNo(formData['hand_railing_yn']),
        '',
      ],
      <String>[''],

      // 7. Block Work
      <String>['7', 'Block Work', '-', '-'],
      <String>[
        'A',
        'Line & Level of Brickwork',
        _getYesNo(formData['brick_work_level_yn']),
        '',
      ],
      <String>[''],

      // 8. Architectural Elevation
      <String>['8', 'Architectural Elevation Features', '-', '-'],
      <String>[
        'A',
        'South side',
        _getYesNo(formData['elevation_south_yn']),
        '',
      ],
      <String>[
        'B',
        'North side',
        _getYesNo(formData['elevation_north_yn']),
        '',
      ],
      <String>['C', 'East side', _getYesNo(formData['elevation_east_yn']), ''],
      <String>['D', 'West side', _getYesNo(formData['elevation_west_yn']), ''],
    ];
  }

  // Helper method to convert Yes/No values
  String _getYesNo(dynamic value) {
    if (value == 'Yes') return 'Yes';
    if (value == 'No') return 'No';
    return 'N/A';
  }

  // Helper method for elevation images
  pw.Widget _buildElevationImage(
    int index,
    List<pw.ImageProvider?> elevImages,
    Map<String, dynamic> imageData,
    String text,
  ) {
    final descKey =
        'elev${index + 1}-Remark'; // Changed to match original format

    if (elevImages[index] != null) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Image(elevImages[index]!, height: 600, fit: pw.BoxFit.contain),
          pw.SizedBox(height: 2),
          pw.Text(
            '$text: ${imageData[descKey] ?? ''}',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 10),
        ],
      );
    } else {
      return pw.SizedBox(height: 0.1);
    }
  }

  // Helper method for other images
  pw.Widget _buildOtherImage(
    int index,
    List<pw.ImageProvider?> imagesList,
    Map<String, dynamic> imageData,
  ) {
    final descKey =
        'img${index + 1}-Remark'; // Changed to match original format

    if (imagesList[index] != null) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 10),
          pw.Image(imagesList[index]!, fit: pw.BoxFit.contain, height: 250),
          pw.SizedBox(height: 2),
          pw.Text(
            'Image ${index + 1}: ${imageData[descKey] ?? ''}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 2),
        ],
      );
    } else {
      return pw.SizedBox(height: 0.1);
    }
  }
}
