import 'package:flutter/material.dart';
//import 'package:face_camera/face_camera.dart';
import 'screens/welcome_screen.dart';
// ignore: unused_import
import 'screens/home_screen.dart';

void main()  {
 // WidgetsFlutterBinding.ensureInitialized();

  // Initialize FaceCamera
  // FaceCamera.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hair Salon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: const WelcomeScreen(),
    );
  }
}
