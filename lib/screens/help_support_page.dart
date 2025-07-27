import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ExpansionTile(
            title: Text('How do I try on hairstyles?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Take or upload a photo, select a hairstyle, and see it overlaid or on a model preview.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I save a hairstyle photo?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Tap the save icon while trying on a hairstyle to save the photo to your gallery.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Can I recommend hairstyles?'),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Hairstyle recommendations are automatic based on your face shape.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
