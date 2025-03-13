import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON

class FormStateNotifier extends StateNotifier<Map<String, dynamic>> {
  FormStateNotifier() : super({}) {
    _loadFormState(); // Load data when initialized
  }

  /// Update a field and save to local storage
  void updateField(String key, dynamic value) {
    state = {...state, key: value};
    _saveFormState();
  }

  /// Load saved form state from SharedPreferences
  Future<void> _loadFormState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('formState');
    if (savedData != null) {
      state = jsonDecode(savedData); // Convert JSON back to a Map
    }
  }

  /// Save the current form state to SharedPreferences
  Future<void> _saveFormState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('formState', jsonEncode(state)); // Convert Map to JSON
  }
}

final formProvider =
    StateNotifierProvider<FormStateNotifier, Map<String, dynamic>>(
      (ref) => FormStateNotifier(),
    );
