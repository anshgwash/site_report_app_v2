import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Define the provider that will be used throughout the app
final formStateProvider =
    StateNotifierProvider<FormStateNotifier, Map<String, dynamic>>(
      (ref) => FormStateNotifier(),
    );

class FormStateNotifier extends StateNotifier<Map<String, dynamic>> {
  FormStateNotifier() : super({}) {
    _loadFormState(); // Load data when initialized
  }

  /// Update a field
  void updateField(String key, dynamic value) {
    // Create a new map to avoid modifying the existing state directly
    final updatedState = Map<String, dynamic>.from(state);
    updatedState[key] = value; // Set the new value for the given key
    state = updatedState; // Update the state
    _saveFormState(); // Save to persistent storage
  }

  /// Update multiple fields at once
  void updateFields(Map<String, dynamic> fields) {
    final updatedState = Map<String, dynamic>.from(state);
    updatedState.addAll(fields); // Add all the new fields
    state = updatedState;
    _saveFormState();
  }

  /// Load saved form state from SharedPreferences
  Future<void> _loadFormState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('formState');
      if (savedData != null) {
        state = Map<String, dynamic>.from(jsonDecode(savedData));
        print('Loaded form state: ${state.length} fields');
      }
    } catch (e) {
      print('Error loading form state: $e');
    }
  }

  /// Save the current form state to SharedPreferences
  Future<void> _saveFormState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('formState', jsonEncode(state));
      print('Saved form state: ${state.length} fields');
    } catch (e) {
      print('Error saving form state: $e');
    }
  }

  /// Clear all form data
  void clearForm() {
    state = {};
    _saveFormState();
  }
}
