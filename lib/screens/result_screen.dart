import 'dart:io';
import 'package:flutter/material.dart';
import 'recommend_hairstyle.dart';
//import 'recommendation_page.dart';

class ResultScreen extends StatelessWidget {
  final File croppedFile;
  final Map<String, dynamic> classificationResult;
  final String gender;

  const ResultScreen({
    super.key,
    required this.croppedFile,
    required this.classificationResult,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final String faceShape = classificationResult['label'] ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Classification Result',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Bold heading
              const Text(
                'Found your Face shape',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Small success text
              Text(
                "Success! We've identified your face shape\nas $faceShape. Now you can explore tips and styles\nthat best suit your unique features.",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Circular cropped image
              Center(
                child: CircleAvatar(
                  radius: 110,
                  backgroundImage: FileImage(croppedFile),
                ),
              ),
              const SizedBox(height: 60),
              // Result text
              Text(
                'Your face shape is $faceShape',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Spacer(),
              // Large gradient button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add your action here
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6D5FFD), Color(0xFF46C7FA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      // child: const Text(
                      //   'Get Suggestions',
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      child: GestureDetector(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder:
                        //           (context) => RecommendationPageHairstyle(
                        //             faceShape:
                        //                 classificationResult['label'] ??
                        //                 'Unknown',
                        //           ),
                        //     ),
                        //   );
                        // },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RecommendationPageHairstyle(
                                    faceShape:
                                        classificationResult['label'] ??
                                        'Unknown',
                                   // gender:
                                        // classificationResult['gender'] ??
                                        // 'female', // or 'male', or any logic you use
                                    //  capturedImage:
                                    gender: gender,
                                    croppedImage:
                                        croppedFile, // you're already passing this into ResultScreen
                                  ),
                            ),
                          );
                        },

                        child: const Text(
                          'Get Suggestions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
