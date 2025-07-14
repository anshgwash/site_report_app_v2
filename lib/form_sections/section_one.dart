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
  List<Map<String, dynamic>> _drawingNumbers = [];
  final List<TextEditingController> _drawingNumberControllers = [];
  final List<String> _drawingTypes = [
    'Arch',
    'Struct',
    'Sect',
    'Elev',
    'Other',
  ];

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize from existing data if available
    _selectedCheckType = widget.formData['typeOfCheck'] as String?;
    _selectedDate = widget.formData['date'] as DateTime?;

    // Initialize drawing numbers from form data
    if (widget.formData.containsKey('drawingNumbers') &&
        widget.formData['drawingNumbers'] is List) {
      _drawingNumbers = List<Map<String, dynamic>>.from(
        (widget.formData['drawingNumbers'] as List).map((item) {
          String type = item['type'];
          switch (type) {
            case 'Architectural':
              type = 'Arch';
              break;
            case 'Structural':
              type = 'Struct';
              break;
            case 'Section':
              type = 'Sect';
              break;
            case 'Elevation':
              type = 'Elev';
              break;
          }
          return {'type': type, 'number': item['number']};
        }),
      );
    } else {
      // Migrate from old data structure
      _drawingNumbers = [];
      final oldDwgFields = {
        'architecturalDwgNo': 'Arch',
        'structuralDwgNo': 'Struct',
        'sectionDwgNo': 'Sect',
        'elevationDwgNo': 'Elev',
      };

      oldDwgFields.forEach((key, type) {
        if (widget.formData.containsKey(key) && widget.formData[key] != null) {
          _drawingNumbers.add({
            'type': type,
            'number': widget.formData[key] as String,
          });
        }
      });
    }

    // Create controllers and add listeners
    for (var i = 0; i < _drawingNumbers.length; i++) {
      var d = _drawingNumbers[i];
      final controller = TextEditingController(text: d['number'] as String?);
      controller.addListener(() {
        _drawingNumbers[i]['number'] = controller.text;
        _updateDrawingNumbersFormData();
      });
      _drawingNumberControllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var controller in _drawingNumberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateDrawingNumbersFormData() {
    final dataToStore =
        _drawingNumbers
            .map((d) => {'type': d['type'], 'number': d['number']})
            .toList();
    widget.updateFormData('drawingNumbers', dataToStore);
  }

  void _addDrawingNumber() {
    setState(() {
      final newDrawing = {'type': 'Arch', 'number': ''};
      _drawingNumbers.add(newDrawing);

      final controller = TextEditingController();
      controller.addListener(() {
        // Find index, in case other items were removed
        final index = _drawingNumberControllers.indexOf(controller);
        if (index != -1) {
          _drawingNumbers[index]['number'] = controller.text;
          _updateDrawingNumbersFormData();
        }
      });
      _drawingNumberControllers.add(controller);
    });
    _updateDrawingNumbersFormData();
  }

  void _removeDrawingNumber(int index) {
    setState(() {
      _drawingNumberControllers[index].dispose();
      _drawingNumberControllers.removeAt(index);
      _drawingNumbers.removeAt(index);
    });
    _updateDrawingNumbersFormData();
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

            _buildDateTimeField(),
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

  Widget _buildDrawingNumbersFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drawing Numbers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._buildDrawingNumberInputs(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _addDrawingNumber,
            icon: const Icon(Icons.add),
            label: const Text('Add Dwgs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[800],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDrawingNumberInputs() {
    if (_drawingNumbers.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              'No drawing numbers added.\nUse the button to add one.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ];
    }

    List<Widget> fields = [];
    for (int i = 0; i < _drawingNumbers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _drawingNumbers[i]['type'] as String,
                  items:
                      _drawingTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _drawingNumbers[i]['type'] = newValue;
                      });
                      _updateDrawingNumbersFormData();
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: _drawingNumberControllers[i],
                  decoration: const InputDecoration(
                    labelText: 'Dwg No.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red[700]),
                onPressed: () => _removeDrawingNumber(i),
                tooltip: 'Remove Drawing Number',
              ),
            ],
          ),
        ),
      );
    }
    return fields;
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

  Widget _buildDateTimeField() {
    final dateText =
        _selectedDate == null
            ? ''
            : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: dateText),
      decoration: const InputDecoration(
        labelText: 'Date',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      onTap: _pickDateTime,
    );
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    setState(() {
      _selectedDate = pickedDate;
      widget.updateFormData('date', _selectedDate);
    });
  }
}
