import 'package:flutter/material.dart';
import '../widgets/section_one.dart';
import '../widgets/section_two.dart';
import '../widgets/section_three.dart';

class FormTab extends StatelessWidget {
  const FormTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [SectionOne(), SectionTwo(), SectionThree()],
      ),
    );
  }
}
