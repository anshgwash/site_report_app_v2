import 'package:flutter/material.dart';

class SectionThree extends StatelessWidget {
  const SectionThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: const [Text('Section Three - Checklist')]),
      ),
    );
  }
}
