import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageProvider =
    StateNotifierProvider<ImageController, Map<String, String>>((ref) {
      return ImageController();
    });

class ImageController extends StateNotifier<Map<String, String>> {
  ImageController() : super({});

  void addImage(String key, String path) {
    state = {...state, key: path};
  }

  void removeImage(String key) {
    state = {...state}..remove(key);
  }
}
