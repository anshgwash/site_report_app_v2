import 'package:flutter_riverpod/flutter_riverpod.dart';

final formProvider =
    StateNotifierProvider<FormController, Map<String, dynamic>>((ref) {
      return FormController();
    });

class FormController extends StateNotifier<Map<String, dynamic>> {
  FormController() : super({});

  void updateField(String key, dynamic value) {
    state = {...state, key: value};
  }
}
