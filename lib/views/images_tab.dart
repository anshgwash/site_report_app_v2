import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/image_provider.dart';

class ImagesTab extends ConsumerWidget {
  const ImagesTab({Key? key}) : super(key: key);

  Future<String?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imageProvider);
    final imageController = ref.read(imageProvider.notifier);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final path = await pickImage();
            if (path != null) {
              imageController.addImage('site_image', path);
            }
          },
          child: const Text('Pick Image'),
        ),
        if (images.containsKey('site_image'))
          Image.file(File(images['site_image']!)),
      ],
    );
  }
}
