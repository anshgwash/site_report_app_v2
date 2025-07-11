import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'providers/form_provider.dart';

class ImagesTab extends ConsumerStatefulWidget {
  const ImagesTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ImagesTab> createState() => _ImagesTabState();
}

class _ImagesTabState extends ConsumerState<ImagesTab> {
  final ImagePicker _picker = ImagePicker();

  // Define the image categories
  final List<Map<String, dynamic>> elevationImages = [
    {'label': 'Front Elevation', 'key': 'elevation_front'},
    {'label': 'Rear Elevation', 'key': 'elevation_rear'},
    {'label': 'Side 1 Elevation', 'key': 'elevation_side1'},
    {'label': 'Side 2 Elevation', 'key': 'elevation_side2'},
  ];

  final List<Map<String, dynamic>> otherImages = List.generate(
    10,
    (index) => {
      'label': 'Image ${index + 1}',
      'key': 'other_image_${index + 1}',
    },
  );

  Future<void> _pickImage(String imageKey) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        ref.read(formStateProvider.notifier).updateField(imageKey, image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _captureImage(String imageKey) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        ref.read(formStateProvider.notifier).updateField(imageKey, image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    }
  }

  Widget _buildImageItem(
    Map<String, dynamic> formData,
    String label,
    String imageKey,
  ) {
    // Get the form data from Riverpod
    final imagePath = formData[imageKey] as String?;
    final descriptionKey = '${imageKey}_description';

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Image preview or placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  imagePath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      )
                      : Center(
                        child: Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
            ),
            const SizedBox(height: 12),

            // Image selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _captureImage(imageKey),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(imageKey),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description field
            TextFormField(
              initialValue: formData[descriptionKey] as String?,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: 'Add a short description',
              ),
              maxLength: 200,
              minLines: 2,
              maxLines: 4,
              onChanged: (value) {
                ref
                    .read(formStateProvider.notifier)
                    .updateField(descriptionKey, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formStateProvider);

    if (formData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elevation Images
            Text(
              'Elevation Images',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...elevationImages.map(
              (image) =>
                  _buildImageItem(formData, image['label'], image['key']),
            ),
            const SizedBox(height: 20),

            // Other Images
            Text(
              'Other Images',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...otherImages.map(
              (image) =>
                  _buildImageItem(formData, image['label'], image['key']),
            ),
          ],
        ),
      ),
    );
  }
}
