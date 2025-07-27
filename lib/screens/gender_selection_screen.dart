// gender_selection_screen.dart
import 'package:flutter/material.dart';

class GenderSelectionScreen extends StatelessWidget {
  final String username;
  final Function(String) onGenderSelected;

  const GenderSelectionScreen({
    required this.username,
    required this.onGenderSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Gender')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Please select your gender:"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onGenderSelected('male'),
            child: const Text("Male"),
          ),
          ElevatedButton(
            onPressed: () => onGenderSelected('female'),
            child: const Text("Female"),
          ),
        ],
      ),
    );
  }
}
