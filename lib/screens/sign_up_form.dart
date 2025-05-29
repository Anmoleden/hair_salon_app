import 'package:flutter/material.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _passwordStrength = "";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    await Future.delayed(const Duration(seconds: 2)); // simulate backend
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fields = [
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

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Sign Up", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 15),

          // Dynamically render fields
          ...fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: TextFormField(
                controller: field["controller"],
                obscureText: field["obscureText"] ?? false,
                keyboardType: field["keyboardType"],
                decoration: InputDecoration(
                  labelText: field["label"],
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      field["isPassword"] == true
                          ? IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: _togglePasswordVisibility,
                          )
                          : null,
                ),
                validator: field["validator"],
                onChanged: field["onChanged"],
              ),
            );
          }),

          // Password Strength Indicator
          if (_passwordStrength.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Password Strength: $_passwordStrength",
                style: TextStyle(
                  color:
                      _passwordStrength == "Weak"
                          ? Colors.red
                          : _passwordStrength == "Medium"
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Sign Up"),
            ),
          ),
        ],
      ),
    );
  }
}
