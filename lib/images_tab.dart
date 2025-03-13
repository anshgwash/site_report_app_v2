import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagesTab extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onImagesChanged;

  const ImagesTab({
    Key? key,
    required this.formData,
    required this.onImagesChanged,
  }) : super(key: key);

  @override
  _ImagesTabState createState() => _ImagesTabState();
}

class _ImagesTabState extends State<ImagesTab> {
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
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        Map<String, dynamic> updatedData = Map.from(widget.formData);
        updatedData[imageKey] = image.path;
        widget.onImagesChanged(updatedData);
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
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        Map<String, dynamic> updatedData = Map.from(widget.formData);
        updatedData[imageKey] = image.path;
        widget.onImagesChanged(updatedData);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    }
  }

  Widget _buildImageItem(String label, String imageKey) {
    final imagePath = widget.formData[imageKey] as String?;
    final descriptionKey = '${imageKey}_description';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Image preview or placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  imagePath != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      )
                      : const Center(child: Text('No image selected')),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(imageKey),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description field
            TextFormField(
              initialValue: widget.formData[descriptionKey] as String?,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                hintText: 'Add a short description',
              ),
              maxLength: 200,
              minLines: 2,
              maxLines: 4,
              onChanged: (value) {
                Map<String, dynamic> updatedData = Map.from(widget.formData);
                updatedData[descriptionKey] = value;
                widget.onImagesChanged(updatedData);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elevation Images
            const Text(
              'Elevation Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...elevationImages.map(
              (image) => _buildImageItem(image['label'], image['key']),
            ),
            const SizedBox(height: 20),

            // Other Images
            const Text(
              'Other Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...otherImages.map(
              (image) => _buildImageItem(image['label'], image['key']),
            ),
          ],
        ),
      ),
    );
  }
}
