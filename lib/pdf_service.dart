import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class PdfService {
  Future<void> generateSiteReportPdf(Map<String, dynamic> formData) async {
    final pdf = pw.Document();

    print('Image keys in formData:');
    formData.keys
        .where(
          (key) =>
              key.startsWith('elevation_') || key.startsWith('other_image_'),
        )
        .forEach((key) => print('$key: ${formData[key]}'));

    List<pw.ImageProvider?> imagesList = List.filled(10, null);
    List<pw.ImageProvider?> elevImages = List.filled(4, null);

    pw.ImageProvider? logoImage;
    try {
      final logoBytes = await rootBundle.load('logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      print('Logo image not found: $e');
    }

    final Map<String, int> elevationIndices = {
      'elevation_front': 0,
      'elevation_rear': 1,
      'elevation_side1': 2,
      'elevation_side2': 3,
    };

    elevationIndices.forEach((key, index) {
      if (formData.containsKey(key) &&
          formData[key] != null &&
          formData[key].toString().isNotEmpty) {
        try {
          String filePath = formData[key];
          print('Loading elevation image for $key from: $filePath');

          final file = File(filePath);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            elevImages[index] = pw.MemoryImage(bytes);
            print('✅ Successfully loaded image for $key');
          } else {
            print('❌ File not found for $key: $filePath');
          }
        } catch (e) {
          print('❌ Error loading elevation image for $key: $e');
        }
      } else {
        print('ℹ️ No image path found for $key');
      }
    });

    for (var i = 1; i <= 10; i++) {
      final imageKey = 'other_image_$i';

      if (formData.containsKey(imageKey) &&
          formData[imageKey] != null &&
          formData[imageKey].toString().isNotEmpty) {
        try {
          String filePath = formData[imageKey];
          print('Loading image for $imageKey from: $filePath');

          final file = File(filePath);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            imagesList[i - 1] = pw.MemoryImage(bytes);
            print('✅ Successfully loaded image $i for $imageKey');
          } else {
            print('❌ File not found for $imageKey: $filePath');
          }
        } catch (e) {
          print('❌ Error loading image for $imageKey: $e');
        }
      } else {
        print('ℹ️ No image path found for $imageKey');
      }
    }

    final List<pw.TableRow> imageRows = [];

    final elevationImageData = [
      {'key': 'elevation_front', 'text': 'Front Elevation', 'index': 0},
      {'key': 'elevation_rear', 'text': 'Rear Elevation', 'index': 1},
      {'key': 'elevation_side1', 'text': 'Side 1 Elevation', 'index': 2},
      {'key': 'elevation_side2', 'text': 'Side 2 Elevation', 'index': 3},
    ];

    for (final data in elevationImageData) {
      final uiKey = data['key'] as String;
      final index = data['index'] as int;
      final text = data['text'] as String;
      final descriptionKey = '${uiKey}_description';
      final description = formData[descriptionKey] as String? ?? '';

      if (elevImages.length > index && elevImages[index] != null) {
        imageRows.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Image(
                  elevImages[index]!,
                  height: 250,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '$text: $description',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }
    }

    for (var i = 0; i < imagesList.length; i++) {
      if (imagesList[i] != null) {
        final uiKey = 'other_image_${i + 1}';
        final descriptionKey = '${uiKey}_description';
        final description = formData[descriptionKey] as String? ?? '';
        imageRows.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Image(
                  imagesList[i]!,
                  height: 250,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  'Image ${i + 1}: $description',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${formData['projectName'] ?? 'Project'}',
                    style: pw.TextStyle(fontSize: 20),
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
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Category', 'Value'],
                <String>['Subject:', '${formData['typeOfCheck'] ?? 'N/A'}'],
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
                <String>['Slab Level:', '${formData['slabLevel'] ?? 'N/A'}'],
                <String>['Date:', '${DateTime.now().toString().split(' ')[0]}'],
                <String>[
                  'Time:',
                  '${DateTime.now().toString().split(' ')[1].substring(0, 5)}',
                ],
                <String>[
                  'Site Report No.:',
                  '${formData['siteReportNo'] ?? 'N/A'}',
                ],
              ],
            ),
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
                <String>['PMC', '${formData['representingPmc'] ?? 'N/A'}'],
              ],
            ),
            pw.Header(
              level: 2,
              child: pw.Text(
                'Following points were observed during site visit',
              ),
            ),
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
            if (imageRows.isNotEmpty)
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                },
                children: imageRows,
              ),
          ];
        },
      ),
    );

    try {
      final output = await getApplicationDocumentsDirectory();
      final projectName = formData['projectName'] ?? 'Project';
      final reportNo = formData['siteReportNo'] ?? 'NA';
      final fileName = '${projectName}_report$reportNo.pdf';
      final file = File('${output.path}/$fileName');

      await file.writeAsBytes(await pdf.save());
      print('📄 PDF saved at: ${file.path}');

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

  String _getYesNo(dynamic value) {
    if (value == 'Yes') return 'Y';
    if (value == 'No') return 'N';
    if (value == 'N/A') return 'NA';
    return '-';
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
        '${formData['correct_drawing_remarks'] ?? ''}',
      ],
      <String>[''],

      // 2. Site Development
      <String>['2', 'Site Development', '-', '-'],
      <String>[
        'A',
        'North of site as per demarcation',
        _getYesNo(formData['north_site_demarcation_yn']),
        '${formData['north_site_demarcation_remarks'] ?? ''}',
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
        '${formData['slab_item_0_remarks'] ?? ''}',
      ],
      <String>[
        'C',
        'Cutout for Plumbing Shaft',
        _getYesNo(formData['slab_item_1_yn']),
        '${formData['slab_item_1_remarks'] ?? ''}',
      ],
      <String>[
        'D',
        'Cutout for Electrical',
        _getYesNo(formData['slab_item_2_yn']),
        '${formData['slab_item_2_remarks'] ?? ''}',
      ],
      <String>[
        'E',
        'Flower Bed Sunk',
        _getYesNo(formData['slab_item_3_yn']),
        '${formData['slab_item_3_remarks'] ?? ''}',
      ],
      <String>[
        'F',
        'Toilet Sunk',
        _getYesNo(formData['slab_item_4_yn']),
        '${formData['slab_item_4_remarks'] ?? ''}',
      ],
      <String>[
        'G',
        'Terrace/Balcony Sunk',
        _getYesNo(formData['slab_item_5_yn']),
        '${formData['slab_item_5_remarks'] ?? ''}',
      ],
      <String>[
        'H',
        'Terrace Projection',
        _getYesNo(formData['slab_item_6_yn']),
        '${formData['slab_item_6_remarks'] ?? ''}',
      ],
      <String>[
        'I',
        'Basements checking',
        _getYesNo(formData['slab_item_7_yn']),
        '${formData['slab_item_7_remarks'] ?? ''}',
      ],
      <String>[
        'J',
        'Size of Column',
        _getYesNo(formData['slab_item_8_yn']),
        '${formData['slab_item_8_remarks'] ?? ''}',
      ],
      <String>[
        'K',
        'Alignment of Column',
        _getYesNo(formData['slab_item_9_yn']),
        '${formData['slab_item_9_remarks'] ?? ''}',
      ],
      <String>[
        'L',
        'Reduction of Column',
        _getYesNo(formData['slab_item_10_yn']),
        '${formData['slab_item_10_remarks'] ?? ''}',
      ],
      <String>[
        'M',
        'Termination of Column',
        _getYesNo(formData['slab_item_11_yn']),
        '${formData['slab_item_11_remarks'] ?? ''}',
      ],
      <String>[
        'N',
        'Beam - Size and Location',
        _getYesNo(formData['slab_item_12_yn']),
        '${formData['slab_item_12_remarks'] ?? ''}',
      ],
      <String>[
        'O',
        'Alignment of Beam Internal',
        _getYesNo(formData['slab_item_13_yn']),
        '${formData['slab_item_13_remarks'] ?? ''}',
      ],
      <String>[
        'P',
        'Electrical Sleeves',
        _getYesNo(formData['slab_item_14_yn']),
        '${formData['slab_item_14_remarks'] ?? ''}',
      ],
      <String>[
        'Q',
        'Plumbing Sleeves',
        _getYesNo(formData['slab_item_15_yn']),
        '${formData['slab_item_15_remarks'] ?? ''}',
      ],
      <String>[
        'R',
        'Hook Fan Location',
        _getYesNo(formData['slab_item_16_yn']),
        '${formData['slab_item_16_remarks'] ?? ''}',
      ],
      <String>[
        'S',
        'Chajja projection & alignment w.r.t slab',
        _getYesNo(formData['slab_item_17_yn']),
        '${formData['slab_item_17_remarks'] ?? ''}',
      ],
      <String>[
        'T',
        'Other slab projections',
        _getYesNo(formData['slab_item_18_yn']),
        '${formData['slab_item_18_remarks'] ?? ''}',
      ],
      <String>[''],

      // 6. Staircase
      <String>['6', 'Staircase', '-', '-'],
      <String>[
        'A',
        'Width of Staircase',
        _getYesNo(formData['staircase_width_yn']),
        '${formData['staircase_width_remarks'] ?? ''}',
      ],
      <String>[
        'B',
        'Dimension of Risers, Treads',
        _getYesNo(formData['staircase_dimensions_yn']),
        '${formData['staircase_dimensions_remarks'] ?? ''}',
      ],
      <String>[
        'C',
        'Mid Landing Level of Staircase',
        _getYesNo(formData['mid_landing_level_yn']),
        '${formData['mid_landing_level_remarks'] ?? ''}',
      ],
      <String>[
        'D',
        'Hand Railing Details',
        _getYesNo(formData['hand_railing_yn']),
        '${formData['hand_railing_remarks'] ?? ''}',
      ],
      <String>[''],

      // 7. Block Work
      <String>['7', 'Block Work', '-', '-'],
      <String>[
        'A',
        'Line & Level of Brickwork',
        _getYesNo(formData['brick_work_level_yn']),
        '${formData['brick_work_level_remarks'] ?? ''}',
      ],
      <String>[''],

      // 8. Architectural Elevation
      <String>['8', 'Architectural Elevation Features', '-', '-'],
      <String>[
        'A',
        'South side',
        _getYesNo(formData['elevation_south_yn']),
        '${formData['elevation_south_remarks'] ?? ''}',
      ],
      <String>[
        'B',
        'North side',
        _getYesNo(formData['elevation_north_yn']),
        '${formData['elevation_north_remarks'] ?? ''}',
      ],
      <String>[
        'C',
        'East side',
        _getYesNo(formData['elevation_east_yn']),
        '${formData['elevation_east_remarks'] ?? ''}',
      ],
      <String>[
        'D',
        'West side',
        _getYesNo(formData['elevation_west_yn']),
        '${formData['elevation_west_remarks'] ?? ''}',
      ],
    ];
  }
}
