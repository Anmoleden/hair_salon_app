import 'package:flutter/material.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate backend
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset link sent to your email.')),
    );
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
    ];

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Reset Password",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 15),

          // Dynamic Field Rendering
          ...fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: field["controller"],
                keyboardType: field["keyboardType"],
                decoration: InputDecoration(
                  labelText: field["label"],
                  border: const OutlineInputBorder(),
                ),
                validator: field["validator"],
              ),
            );
          }),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Send Reset Link"),
            ),
          ),
        ],
      ),
    );
  }
}
