import 'package:flutter/material.dart';
import 'package:hair_salon/screens/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _passwordStrength = "";

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //added part
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
 
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _updatePasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = "";
    } else if (password.length < 6) {
      _passwordStrength = "Weak";
    } else if (password.length < 10) {
      _passwordStrength = "Medium";
    } else {
      _passwordStrength = "Strong";
    }
    setState(() {});
  }

  Future<void> _handleSignUp() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  final url = ApiConfig.getSignupUri();

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim().toLowerCase(),
        "password": _passwordController.text.trim(),
        //added part
        "gender": _selectedGender,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Signup Successful")),
      );
      Navigator.of(context).pop(); // Back to login screen
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "User already exists")),
      );
      await Future.delayed(Duration(seconds: 2)); // Show message briefly
      Navigator.of(context).pop(); // Back to login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["error"] ?? data["message"] ?? "Signup failed")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  }
  setState(() => _isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fields = [
      {
        "label": "Username",
        "controller": _usernameController,
        "keyboardType": TextInputType.text,
        "validator": (value) {
          if (value == null || value.isEmpty) return 'Username is required';
          if (value.length < 3) return 'Username must be at least 3 characters';
          return null;
        },
      },
      {
        "label": "Email",
        "controller": _emailController,
        "keyboardType": TextInputType.emailAddress,
        "validator": (value) {
          if (value == null || value.isEmpty) return 'Email is required';
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
          return null;
        },
      },
      {
        "label": "Password",
        "controller": _passwordController,
        "obscureText": _obscurePassword,
        "isPassword": true,
        "validator": (value) {
          if (value == null || value.isEmpty) return 'Password is required';
          if (value.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
        "onChanged": _updatePasswordStrength,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0.5),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // onPressed: () => Navigator.of(context).pop(),
          onPressed: () => Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          ),

        ),
      ),
      body: SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.cyan],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),

                ...fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: TextFormField(
                      controller: field["controller"],
                      obscureText: field["obscureText"] ?? false,
                      keyboardType: field["keyboardType"],
                      onChanged: field["onChanged"],
                      validator: field["validator"],
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: field["label"],
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: field["isPassword"] == true
                            ? IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePasswordVisibility,
                              )
                            : null,
                      ),
                    ),
                  );
                }),

                //added part
                 /// ✅ Gender Dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: _genderOptions
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select your gender' : null,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),

                if (_passwordStrength.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "Password Strength: $_passwordStrength",
                      style: TextStyle(
                        color: _passwordStrength == "Weak"
                            ? Colors.red
                            : _passwordStrength == "Medium"
                                ? Colors.orange
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
