import 'package:flutter/material.dart';
import 'form_sections/section_one.dart';
import 'form_sections/section_two.dart';
import 'form_sections/section_three.dart';

class FormTab extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onFormDataChanged;

  const FormTab({
    Key? key,
    required this.formKey,
    required this.formData,
    required this.onFormDataChanged,
  }) : super(key: key);

  @override
  _FormTabState createState() => _FormTabState();
}

class _FormTabState extends State<FormTab> {
  // Method to update the form data
  void _updateFormData(String key, dynamic value) {
    Map<String, dynamic> updatedData = Map.from(widget.formData);
    updatedData[key] = value;
    widget.onFormDataChanged(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Site Report Info
              SectionOne(
                formData: widget.formData,
                updateFormData: _updateFormData,
              ),
              const SizedBox(height: 20),

              // Section 2: Attendance List
              SectionTwo(
                formData: widget.formData,
                updateFormData: _updateFormData,
              ),
              const SizedBox(height: 20),

              // Section 3: Checklist
              SectionThree(
                formData: widget.formData,
                updateFormData: _updateFormData,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
