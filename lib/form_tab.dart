import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'form_sections/section_one.dart';
import 'form_sections/section_two.dart';
import 'form_sections/section_three.dart';
import 'providers/form_provider.dart';

class FormTab extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  const FormTab({Key? key, required this.formKey}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get form data from provider
    final formData = ref.watch(formStateProvider);
    final formVersion = ref.watch(formVersionProvider);

    // Show a loader while data is loading
    if (formData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Function to update form data
    void updateFormData(String key, dynamic value) {
      ref.read(formStateProvider.notifier).updateField(key, value);
    }

    return Scaffold(
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          key: ValueKey(
            formVersion,
          ), // This will force rebuild when form is cleared
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Site Report Info
              SectionOne(formData: formData, updateFormData: updateFormData),
              const SizedBox(height: 20),

              // Section 2: Attendance List
              SectionTwo(formData: formData, updateFormData: updateFormData),
              const SizedBox(height: 20),

              // Section 3: Checklist
              SectionThree(formData: formData, updateFormData: updateFormData),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
