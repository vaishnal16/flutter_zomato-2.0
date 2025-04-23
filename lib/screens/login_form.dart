import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class LoginForm extends StatefulWidget {
  final String email;
  final Function() onLoginSuccess;
  final Function() onCancel;

  const LoginForm({
    Key? key,
    required this.email,
    required this.onLoginSuccess,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-login when form is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _login();
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Normalize the email
      final normalizedEmail = widget.email.trim().toLowerCase();

      final userModel = Provider.of<UserModel>(context, listen: false);
      // Direct login with email only (using normalized email)
      await userModel.signInWithEmailOnly(normalizedEmail);

      // Call the success callback
      widget.onLoginSuccess();
    } catch (e) {
      final errorMessage = e.toString();
      print('Login form error: $errorMessage');

      // If email is already registered, consider it a successful login
      if (errorMessage.contains('already registered') ||
          errorMessage.contains('already in use')) {
        print('Email exists, redirecting to home');
        widget.onLoginSuccess();
        return;
      }

      setState(() {
        _isLoading = false;

        // Format the error message to be more user-friendly
        if (errorMessage.contains('User not found') ||
            errorMessage.contains('Account not found')) {
          _errorMessage = 'Account not found. Please sign up instead.';
        } else if (errorMessage.contains('network')) {
          _errorMessage =
              'Network error. Please check your internet connection.';
        } else if (errorMessage.contains('admin-restricted-operation')) {
          _errorMessage =
              'Login failed due to security restrictions. This is a demo limitation - please try a different email.';
        } else if (errorMessage.contains('password may be different')) {
          _errorMessage =
              'This email is registered but with a different password. For this demo, please try another email.';
        } else {
          _errorMessage =
              'Login failed: ${errorMessage.split('Exception: ').last}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            text: 'Welcome back! Signing you in with ',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE23744),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Loading indicator
        if (_isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFFE23744),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logging you in...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE23744),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Signing in with ${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE23744),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      disabledBackgroundColor:
                          const Color(0xFFE23744).withOpacity(0.4),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Cancel button (only shown when there's an error)
        if (_errorMessage != null)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: widget.onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
