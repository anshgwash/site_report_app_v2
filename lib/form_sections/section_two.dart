import 'package:flutter/material.dart';

/// Section Two of the site report form containing attendance list information
class SectionTwo extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) updateFormData;

  const SectionTwo({
    Key? key,
    required this.formData,
    required this.updateFormData,
  }) : super(key: key);

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
            _buildSectionHeader('Section 2: Attendance List'),
            const SizedBox(height: 24),

            _buildAttendanceFields(context),
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

  Widget _buildAttendanceFields(BuildContext context) {
    return Column(
      children: [
        _buildAttendeeField(
          label: 'Representing Architect',
          icon: Icons.architecture,
          fieldKey: 'representingArchitect',
        ),
        const SizedBox(height: 16),

        _buildAttendeeField(
          label: 'Representing Contractor',
          icon: Icons.engineering,
          fieldKey: 'representingContractor',
        ),
        const SizedBox(height: 16),

        _buildAttendeeField(
          label: 'Representing Client',
          icon: Icons.person,
          fieldKey: 'representingClient',
        ),

        const SizedBox(height: 16),
        _buildAttendeeField(
          label: 'Representing PMC',
          icon: Icons.person,
          fieldKey: 'representingPmc',
        ),
      ],
    );
  }

  Widget _buildAttendeeField({
    required String label,
    required IconData icon,
    required String fieldKey,
  }) {
    return TextFormField(
      initialValue: formData[fieldKey] as String?,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        hintText: 'Enter name',
      ),
      onChanged: (value) {
        updateFormData(fieldKey, value);
      },
    );
  }
}
