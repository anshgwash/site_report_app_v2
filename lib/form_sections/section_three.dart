import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Section Three of the site report form containing checklist information
class SectionThree extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) updateFormData;

  const SectionThree({
    Key? key,
    required this.formData,
    required this.updateFormData,
  }) : super(key: key);

  @override
  State<SectionThree> createState() => _SectionThreeState();
}

class _SectionThreeState extends State<SectionThree> {
  // Expanded section trackers
  final Map<String, bool> _expandedSections = {
    'drawing': true,
    'siteDevelopment': true,
    'centerLine': true,
    'shuttering': true,
    'slabChecking': true,
    'staircase': true,
    'blockWork': true,
    'elevation': true,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Section 3: Checklist'),
            const SizedBox(height: 16),

            // 1. Drawing on Site Audit
            _buildExpandableSection(
              title: '1 - Drawing on Site Audit',
              sectionKey: 'drawing',
              children: [
                _buildYesNoField(
                  title: 'Correct and latest drawing being referred',
                  fieldName: 'correct_drawing',
                ),
              ],
            ),

            // 2. Site Development
            _buildExpandableSection(
              title: '2 - Site Development',
              sectionKey: 'siteDevelopment',
              children: [
                _buildYesNoField(
                  title: 'North of site as per demarcation',
                  fieldName: 'north_site_demarcation',
                ),
                _buildYesNoField(
                  title: 'UG tanks top slab level marking',
                  fieldName: 'ug_tanks_level',
                  hasRemarks: true,
                ),
                _buildYesNoField(
                  title: 'Site levels marking w.r.t road level',
                  fieldName: 'site_levels_road',
                  hasRemarks: true,
                ),
              ],
            ),

            // 3. Setting Out & Center Line Checking
            _buildExpandableSection(
              title: '3 - Setting Out & Center Line Checking',
              sectionKey: 'centerLine',
              children: [
                _buildYesNoField(
                  title: 'Open offset dimension',
                  fieldName: 'offset_dimension',
                  hasRemarks: true,
                ),
                _buildYesNoField(
                  title: 'Column marking as per center line',
                  fieldName: 'column_marking',
                  hasRemarks: true,
                ),
              ],
            ),

            // 4. Shuttering Check
            _buildExpandableSection(
              title: '4 - Shuttering Check',
              sectionKey: 'shuttering',
              children: [
                _buildYesNoField(
                  title: 'Overall checking - supporting level, no gaps, etc.',
                  fieldName: 'shuttering_check',
                  hasRemarks: true,
                ),
              ],
            ),

            // 5. Slab Checking
            _buildExpandableSection(
              title: '5 - Slab Checking',
              sectionKey: 'slabChecking',
              children: [_buildSlabLevelField(), ..._buildSlabCheckingFields()],
            ),

            // 6. Staircase
            _buildExpandableSection(
              title: '6 - Staircase',
              sectionKey: 'staircase',
              children: [
                _buildYesNoField(
                  title: 'Width of Staircase',
                  fieldName: 'staircase_width',
                ),
                _buildYesNoField(
                  title: 'Dimensions of risers/treads',
                  fieldName: 'staircase_dimensions',
                ),
                _buildYesNoField(
                  title: 'Mid Landing Level',
                  fieldName: 'mid_landing_level',
                ),
              ],
            ),

            // 7. Block Work
            _buildExpandableSection(
              title: '7 - Block Work',
              sectionKey: 'blockWork',
              children: [
                _buildYesNoField(
                  title: 'Line and Level of Brick Work',
                  fieldName: 'brick_work_level',
                ),
              ],
            ),

            // 8. Architectural Elevation Features
            _buildExpandableSection(
              title: '8 - Architectural Elevation Features',
              sectionKey: 'elevation',
              children: [
                _buildYesNoField(
                  title: 'South Side',
                  fieldName: 'elevation_south',
                ),
                _buildYesNoField(
                  title: 'North Side',
                  fieldName: 'elevation_north',
                ),
                _buildYesNoField(
                  title: 'East Side',
                  fieldName: 'elevation_east',
                ),
                _buildYesNoField(
                  title: 'West Side',
                  fieldName: 'elevation_west',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String sectionKey,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedSections[sectionKey] =
                  !(_expandedSections[sectionKey] ?? false);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _expandedSections[sectionKey] ?? false
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expandedSections[sectionKey] ?? false)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        const Divider(),
      ],
    );
  }

  Widget _buildYesNoField({
    required String title,
    required String fieldName,
    bool hasRemarks = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Row(
            children: [
              Radio<String>(
                value: 'Yes',
                groupValue: widget.formData['${fieldName}_yn'] as String?,
                onChanged: (value) {
                  setState(() {
                    widget.updateFormData('${fieldName}_yn', value);
                  });
                },
              ),
              const Text('Yes'),
              const SizedBox(width: 16),
              Radio<String>(
                value: 'No',
                groupValue: widget.formData['${fieldName}_yn'] as String?,
                onChanged: (value) {
                  setState(() {
                    widget.updateFormData('${fieldName}_yn', value);
                  });
                },
              ),
              const Text('No'),
            ],
          ),
          if (hasRemarks) ...[
            const SizedBox(height: 4),
            TextFormField(
              initialValue: widget.formData['${fieldName}_remarks'] as String?,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              onChanged: (value) {
                widget.updateFormData('${fieldName}_remarks', value);
              },
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSlabLevelField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: widget.formData['level_of_slab']?.toString(),
        decoration: const InputDecoration(
          labelText: 'Level of slab',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.height),
          hintText: 'Enter a value between 1-100',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            int? level = int.tryParse(value);
            if (level == null || level < 1 || level > 100) {
              return 'Level must be between 1 and 100';
            }
          }
          return null;
        },
        onChanged: (value) {
          widget.updateFormData(
            'level_of_slab',
            value.isEmpty ? null : int.tryParse(value),
          );
        },
      ),
    );
  }

  List<Widget> _buildSlabCheckingFields() {
    final slabItems = [
      'Cut-out for lift dimension',
      'Cut-out for plumbing shaft',
      'Cut-out for electrical',
      'Flower bed sunk',
      'Toilet sunk',
      'Terrace/balcony sunk',
      'Terrace projection',
      'Basement checking',
      'Size of column',
      'Alignment of column',
      'Reduction of column',
      'Beam size and location',
      'Alignment of beam (internal, external, w.r.t slab level)',
      'Electrical sleeves',
      'Plumbing sleeves',
      'Hook fan location',
      'Chajja projection & alignment w.r.t slab',
      'Other slab projections',
    ];

    return slabItems.asMap().entries.map((entry) {
      final fieldName = 'slab_item_${entry.key}';
      return _buildYesNoField(title: entry.value, fieldName: fieldName);
    }).toList();
  }
}
