// welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_screen.dart';
import 'sign_up_form.dart';
import 'forgot_password_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        '582706976380-3trf12q18qu3d7dagp8u40amv51th57g.apps.googleusercontent.com',
  );
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

  // Toggles the visibility of the password
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  // Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // Login action with simple validation
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // final url = Uri.parse("http://192.168.1.64:8080/signin");
    final url = ApiConfig.getLoginUri();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        //add part
        final username = data['user']['fullname'] as String;
        final gender = data['user']['gender'] as String;
        final userId = data['user']['_id'];

        await secureStorage.write(key: 'userId', value: userId);
        //navigate on success
        Navigator.push(
          context,
          MaterialPageRoute(
            //builder: (_) => const HomeScreen(loginMethod: 'Email'),
            //add part
            builder:
                (_) => HomeScreen(
                  username: username,
                  gender: gender,
                  loginMethod: 'Email',
                ),
          ),
        );
      } else {
        _showErrorSnackBar(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Network error: $e');
    }
  }

  // Future<void> _googleLogin() async {
  //   setState(() => _isLoading = true);

  //   try {
  //     await _googleSignIn.signOut(); // optional

  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       _showErrorSnackBar('Google sign-in was cancelled.');
  //       return;
  //     }

  //     final googleAuth = await googleUser.authentication;
  //     final String? idToken = googleAuth.idToken;

  //     if (idToken == null) {
  //       _showErrorSnackBar('Failed to get ID token.');
  //       return;
  //     }

  //     // Send to backend
  //     final response = await http.post(
  //       // Uri.parse('http://192.168.1.64:8080/google-signin'),
  //       // Uri.parse('${ApiConfig.baseUrl}/google-signin'),
  //       ApiConfig.getGoogleSignInUri(),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'idToken': idToken}),
  //     );

  //     final result = jsonDecode(response.body);

  //     // print('Google login response: $result');

  //     if (response.statusCode == 200) {
  //       final token = result['token'] as String;
  //       //final username = result['user']['username'] as String;

  //       // final user = result['user'];

  //       //added part
  //       final username =
  //           (result['user']['username'] ?? result['user']['name']) as String;
  //       final email = result['user']['email'] as String;
  //       final photo = (result['user']['photo'] ?? '') as String;
  //       final userId = result['user']['_id'];
  //       final gender = result['user']['gender'];

  //       //  Save token securely
  //       await secureStorage.write(key: 'jwtToken', value: token);
  //       //added part
  //       await secureStorage.write(key: 'username', value: username);
  //       await secureStorage.write(key: 'email', value: email);
  //       await secureStorage.write(key: 'photo', value: photo);

  //       await secureStorage.write(key: 'userId', value: userId);
  //       // Navigate to home screen or wherever
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder:
  //               (_) => HomeScreen(
  //                 username: username,
  //                 //added part
  //                 loginMethod: 'Google',
  //                 //added part
  //               ),
  //         ),
  //       );
  //     } else {
  //       _showErrorSnackBar('Login failed: ${result['error']}');
  //     }
  //   } catch (e) {
  //     _showErrorSnackBar('Login error: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // 🔽 Paste it inside your State class:
  // Future<String?> _showGenderPopup(BuildContext context) async {
  //   return await showModalBottomSheet<String>(
  //     context: context,
  //     isDismissible: false,
  //     enableDrag: false,
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Select Your Gender',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 20),
  //             ListTile(
  //               title: const Text('Male'),
  //               onTap: () => Navigator.pop(context, 'Male'),
  //             ),
  //             ListTile(
  //               title: const Text('Female'),
  //               onTap: () => Navigator.pop(context, 'Female'),
  //             ),
  //             ListTile(
  //               title: const Text('Other'),
  //               onTap: () => Navigator.pop(context, 'Other'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<String?> _showGenderPopup(BuildContext context) async {
    final theme = Theme.of(context);

    return await showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor:
          theme.scaffoldBackgroundColor, // Match welcome screen background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Your Gender',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor, // Use primary app color
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.male, color: Colors.blue),
                title: const Text('Male'),
                onTap: () => Navigator.pop(context, 'Male'),
              ),
              ListTile(
                leading: const Icon(Icons.female, color: Colors.pink),
                title: const Text('Female'),
                onTap: () => Navigator.pop(context, 'Female'),
              ),
              ListTile(
                leading: const Icon(Icons.transgender, color: Colors.purple),
                title: const Text('Other'),
                onTap: () => Navigator.pop(context, 'Other'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);

    try {
      await _googleSignIn.signOut(); // optional

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showErrorSnackBar('Google sign-in was cancelled.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _showErrorSnackBar('Failed to get ID token.');
        return;
      }

      final response = await http.post(
        ApiConfig.getGoogleSignInUri(),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = result['token'] as String;
        final username =
            (result['user']['username'] ?? result['user']['name']) as String;
        final email = result['user']['email'] as String;
        final photo = (result['user']['photo'] ?? '') as String;
        final userId = result['user']['_id'];
        final gender = result['user']['gender']; // ✅ gender fetched

        await secureStorage.write(key: 'jwtToken', value: token);
        await secureStorage.write(key: 'username', value: username);
        await secureStorage.write(key: 'email', value: email);
        await secureStorage.write(key: 'photo', value: photo);
        await secureStorage.write(key: 'userId', value: userId);

        //String finalGender = gender;

        if (gender == null || gender.isEmpty) {
          final selectedGender = await _showGenderPopup(context);

          if (selectedGender == null) {
            _showErrorSnackBar('Gender selection is required.');
            return;
          }

          final genderResponse = await http.put(
            ApiConfig.getUpdateGenderUri(),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'gender': selectedGender}),
          );

          if (genderResponse.statusCode != 200) {
            _showErrorSnackBar('Failed to update gender on backend.');
            return;
          }
          await secureStorage.write(key: 'gender', value: selectedGender);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => HomeScreen(
                    username: username,
                    gender: selectedGender,
                    loginMethod: 'Google',
                  ),
            ),
          );
        } else {
          // ✅ Add this missing navigation
          await secureStorage.write(key: 'gender', value: gender);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => HomeScreen(
                    username: username,
                    gender: gender,
                    loginMethod: 'Google',
                  ),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Login failed: ${result['error']}');
      }
    } catch (e) {
      _showErrorSnackBar('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //add part
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  // Forgot Password dialog
  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(child: const ForgotPasswordForm()),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height; // ADD this
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: screenHeight, // make the container full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.cyan],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : 40,
            vertical:
                screenHeight * 0.1, // Adjust vertical padding using height
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/hairstyle.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              // Login Form with validation
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Login button with loading indicator
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.indigo,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text(
                            'Login',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign Up option
              _buildSignUpOption(),
              const SizedBox(height: 20),
              // OR divider with styling
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Expanded(child: Divider(color: Colors.white70)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 20),
              // Google login button with loading indicator
              IconButton(
                iconSize: 48,
                icon:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.g_mobiledata, color: Colors.white),
                onPressed: _isLoading ? null : _googleLogin,
                tooltip: "Login with Google",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField with validator support
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  // Sign Up option row widget
  Widget _buildSignUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: _navigateToSignUp,
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
