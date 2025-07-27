import 'package:flutter/material.dart';
// import 'package:face_camera/face_camera.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'screens/welcome_screen.dart';
// ignore: unused_import
import 'screens/home_screen.dart';
import 'screens/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FaceCamera.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late final AppLinks _appLinks;

  Widget _initialScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _forceLogoutAndInit(); // Clear tokens and set initial screen
  }

  Future<void> _forceLogoutAndInit() async {
    // Clear any saved tokens or sign-in states
    await secureStorage.delete(key: 'jwtToken');
    await _googleSignIn.signOut();

    _setupDeepLinks();
  }

  void _setupDeepLinks() async {
    _appLinks = AppLinks();

    try {
      Uri? uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        _handleDeepLink(uri);
      } else {
        setState(() => _initialScreen = const WelcomeScreen());
      }

      _appLinks.uriLinkStream.listen((uri) {
        // ignore: unnecessary_null_comparison
        if (uri != null) _handleDeepLink(uri);
      });
    } catch (e) {
      debugPrint("Deep link initialization failed: $e");
      setState(() => _initialScreen = const WelcomeScreen());
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("Received deep link: $uri");

    if (uri.pathSegments.contains('reset-password')) {
      final token = uri.pathSegments.last;
      setState(() {
        _initialScreen = ResetPasswordScreen(token: token);
      });
    } else {
      setState(() => _initialScreen = const WelcomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hair Salon App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      ),
      home: _initialScreen,
    );
  }
}

extension on AppLinks {
  Future<Uri?> getInitialAppLink() {
    return Future.value(null);
  }
}