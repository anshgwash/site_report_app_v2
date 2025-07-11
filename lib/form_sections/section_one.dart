import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Section One of the site report form containing basic report information
class SectionOne extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) updateFormData;

  const SectionOne({
    Key? key,
    required this.formData,
    required this.updateFormData,
  }) : super(key: key);

  @override
  State<SectionOne> createState() => _SectionOneState();
}

class _SectionOneState extends State<SectionOne> {
  // Choice chip options
  final List<String> _checkTypes = [
    'General',
    'Centerline',
    'Plinth',
    'Slab',
    'Brick Work',
  ];

  String? _selectedCheckType;

  @override
  void initState() {
    super.initState();
    // Initialize from existing data if available
    _selectedCheckType = widget.formData['typeOfCheck'] as String?;
  }

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
            _buildSectionHeader('Section 1: Site Report Info'),
            const SizedBox(height: 24),

            _buildProjectNameField(),
            const SizedBox(height: 16),

            _buildTypeOfCheckChips(),
            const SizedBox(height: 16),

            _buildDrawingNumbersFields(),
            const SizedBox(height: 16),

            _buildSlabLevelField(),
            const SizedBox(height: 16),

            _buildSiteReportNumberField(),
            const SizedBox(height: 16),
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

  Widget _buildProjectNameField() {
    return TextFormField(
      initialValue: widget.formData['projectName'] as String?,
      decoration: const InputDecoration(
        labelText: 'Project Name *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      maxLength: 100,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Project name is required';
        }
        return null;
      },
      onChanged: (value) {
        widget.updateFormData('projectName', value);
      },
    );
  }

  Widget _buildTypeOfCheckChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type of Check:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              _checkTypes.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedCheckType == type,
                  selectedColor: Colors.blue.shade100,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCheckType = selected ? type : null;
                      widget.updateFormData('typeOfCheck', _selectedCheckType);
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrawingNumbersFields() {
    return Column(
      children: [
        TextFormField(
          initialValue: widget.formData['architecturalDwgNo'] as String?,
          decoration: const InputDecoration(
            labelText: 'Architectural Dwg No.',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.architecture),
          ),
          onChanged: (value) {
            widget.updateFormData('architecturalDwgNo', value);
          },
        ),
        const SizedBox(height: 12),

        TextFormField(
          initialValue: widget.formData['structuralDwgNo'] as String?,
          decoration: const InputDecoration(
            labelText: 'Structural Dwg No.',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.domain),
          ),
          onChanged: (value) {
            widget.updateFormData('structuralDwgNo', value);
          },
        ),
        const SizedBox(height: 12),

        TextFormField(
          initialValue: widget.formData['sectionDwgNo'] as String?,
          decoration: const InputDecoration(
            labelText: 'Section Dwg No.',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.splitscreen),
          ),
          onChanged: (value) {
            widget.updateFormData('sectionDwgNo', value);
          },
        ),
        const SizedBox(height: 12),

        TextFormField(
          initialValue: widget.formData['elevationDwgNo'] as String?,
          decoration: const InputDecoration(
            labelText: 'Elevation Dwg No.',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.layers),
          ),
          onChanged: (value) {
            widget.updateFormData('elevationDwgNo', value);
          },
        ),
      ],
    );
  }

  Widget _buildSlabLevelField() {
    return TextFormField(
      initialValue: widget.formData['slabLevel']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Slab Level',
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
            return 'Slab level must be between 1 and 100';
          }
        }
        return null;
      },
      onChanged: (value) {
        widget.updateFormData(
          'slabLevel',
          value.isEmpty ? null : int.tryParse(value),
        );
      },
    );
  }

  Widget _buildSiteReportNumberField() {
    return TextFormField(
      initialValue: widget.formData['siteReportNo']?.toString(),
      decoration: const InputDecoration(
        labelText: 'Site Report No. *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.numbers),
        hintText: 'Enter a value between 1-100',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Site report number is required';
        }
        int? reportNo = int.tryParse(value);
        if (reportNo == null || reportNo < 1 || reportNo > 100) {
          return 'Site report number must be between 1 and 100';
        }
        return null;
      },
      onChanged: (value) {
        widget.updateFormData(
          'siteReportNo',
          value.isEmpty ? null : int.tryParse(value),
        );
      },
    );
  }
}
