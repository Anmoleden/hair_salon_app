import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:bot_toast/bot_toast.dart';

class HairstyleEditorScreen extends StatelessWidget {
  final File baseImage;
  final String hairAssetPath; // optional overlay asset path
  final bool isMale;

  const HairstyleEditorScreen({
    super.key,
    required this.baseImage,
    required this.hairAssetPath,
    required this.isMale,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: baseImage.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ProImageEditor.memory(
          snapshot.data!,
          configs: const ProImageEditorConfigs(
            // Add any valid configuration parameters here if needed
          ),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List? editedImage) async {
              if (editedImage != null) {
                BotToast.showText(text: "Image edited");
                Navigator.pop(context, editedImage);
                return;
              }
              return;
            },
            onCloseEditor: (editorMode) {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}