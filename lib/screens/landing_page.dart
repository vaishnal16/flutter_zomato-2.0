import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../config/email_config.dart';
import 'login_form.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final TextEditingController _emailOTPController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isEmailSelected = true;
  bool _isSendingLink = false;
  bool _isVerifyingPhone = false;
  bool _showVerificationCodeField = false;
  bool _showEmailOTPField = false;
  bool _showLoginForm = false;
  String? _errorMessage;
  bool _linkSent = false;
  String? _emailOTP;

  // Use more reliable image URLs or consider using asset images
  final String _logoUrl =
      'https://b.zmtcdn.com/web_assets/8313a97515fcb0447d2d77c276532a511583262271.png';
  final String _foodImageUrl =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=80';
  final String _googleIconUrl =
      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg';
  final String _facebookIconUrl =
      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/facebook.svg';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkIfButtonEnabled);
    _phoneController.addListener(_checkIfButtonEnabled);

    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      if (userModel.isAuthenticated) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _emailOTPController.dispose();
    super.dispose();
  }

  void _checkIfButtonEnabled() {
    setState(() {
      if (_isEmailSelected) {
        _isButtonEnabled = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text);
      } else {
        _isButtonEnabled = _phoneController.text.length >= 10;
      }
    });
  }

  Future<void> _sendEmailOTP() async {
    if (!_isButtonEnabled) return;

    final email = _emailController.text.trim().toLowerCase();

    // Update UI
    setState(() {
      _isSendingLink = true;
      _errorMessage = null;
    });

    try {
      // First check if the email already exists
      final authService = AuthService();
      final emailExists = await authService.checkIfEmailExists(email);

      if (emailExists) {
        // If email exists, show login form instead
        setState(() {
          _isSendingLink = false;
          _showLoginForm = true;
        });
        return;
      }

      // If email doesn't exist, continue with OTP flow
      final userModel = Provider.of<UserModel>(context, listen: false);
      await userModel.sendEmailOTP(email);

      // Update UI to show OTP input field
      setState(() {
        _isSendingLink = false;
        _showEmailOTPField = true;
      });
    } catch (e) {
      // Update UI to show error
      setState(() {
        _isSendingLink = false;
        _errorMessage = 'Failed to send OTP: ${e.toString()}';
      });
    }
  }

  Future<void> _verifyEmailOTP() async {
    final email = _emailController.text.trim();
    final otp = _emailOTPController.text.trim();

    if (otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isSendingLink = true;
      _errorMessage = null;
    });

    try {
      final userModel = Provider.of<UserModel>(context, listen: false);
      await userModel.verifyEmailOTP(email, otp);

      // Navigate to home on success
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isSendingLink = false;
        // Check if it's an existing email error
        if (e.toString().contains('already registered') ||
            e.toString().contains('already in use')) {
          // Show dialog for existing account
          if (mounted) {
            _showExistingAccountDialog(email);
          }
        } else {
          _errorMessage = 'Failed to verify OTP: ${e.toString()}';
        }
      });
    }
  }

  // Show dialog when email is already registered
  void _showExistingAccountDialog(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Already Exists'),
          content: Text(
            'The email $email is already registered. What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear the email field to let user try another
                setState(() {
                  _showEmailOTPField = false;
                  _emailController.clear();
                  _emailOTPController.clear();
                });
              },
              child: const Text('Use Different Email'),
            ),
            // Login with this email
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE23744),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Show login form
                setState(() {
                  _showEmailOTPField = false;
                  _emailOTPController.clear();
                  _showLoginForm = true;
                });
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startPhoneVerification() async {
    if (!_isButtonEnabled) return;

    final phone = _phoneController.text.trim();

    // Make sure phone has + prefix
    final formattedPhone = phone.startsWith('+') ? phone : '+$phone';

    setState(() {
      _isVerifyingPhone = true;
      _errorMessage = null;
    });

    try {
      final userModel = Provider.of<UserModel>(context, listen: false);
      await userModel.startPhoneVerification(formattedPhone);

      // Show verification code field
      setState(() {
        _isVerifyingPhone = false;
        _showVerificationCodeField = true;
      });
    } catch (e) {
      setState(() {
        _isVerifyingPhone = false;
        _errorMessage = 'Failed to send verification code: ${e.toString()}';
      });
    }
  }

  Future<void> _verifyPhoneCode() async {
    final code = _smsCodeController.text.trim();

    if (code.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isVerifyingPhone = true;
      _errorMessage = null;
    });

    try {
      final userModel = Provider.of<UserModel>(context, listen: false);
      await userModel.verifyPhoneWithCode(code);

      // Navigate to home on success
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isVerifyingPhone = false;
        _errorMessage = 'Failed to verify code: ${e.toString()}';
      });
    }
  }

  // Move to login form for existing users
  void _goToLoginForm() {
    if (!_isButtonEnabled) return;

    setState(() {
      _showLoginForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Make the gradient dark red like Zomato
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              const Color(0xFFE23744), // Solid red at the top
              const Color(0xFFE23744).withOpacity(0.8),
              const Color(0xFFE23744).withOpacity(0.6),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // App logo - larger and more prominent
                Center(
                  child: _buildNetworkImage(
                    _logoUrl,
                    height: 60,
                    fallbackIcon: Icons.restaurant,
                  ),
                ),
                const SizedBox(height: 60),

                // Hero image for food
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE23744).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildNetworkImage(
                      _foodImageUrl,
                      width: screenSize.width * 0.8,
                      fallbackIcon: Icons.image,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Welcome text
                RichText(
                  text: const TextSpan(
                    text: 'India\'s ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: '#1 ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Food Delivery App',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Log in to unlock exclusive features',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Toggle between email and phone
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton('Email', true),
                      _buildToggleButton('Phone', false),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Input field (email or phone based on selection)
                _isEmailSelected
                    ? _buildInputField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                      )
                    : _buildInputField(
                        controller: _phoneController,
                        hintText: 'Phone',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                      ),

                // Show error message if any
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled &&
                            !_isSendingLink &&
                            !_isVerifyingPhone
                        ? _isEmailSelected
                            ? _sendEmailOTP
                            : _startPhoneVerification
                        : null,
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
                    child: _isSendingLink || _isVerifyingPhone
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : Text(
                            _isEmailSelected
                                ? 'Sign Up with Email'
                                : 'Sign Up with Phone',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // Login button for existing users
                if (_isEmailSelected)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: (_isButtonEnabled &&
                              !_isSendingLink &&
                              !_isVerifyingPhone)
                          ? _goToLoginForm
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE23744),
                        side: const BorderSide(
                            color: Color(0xFFE23744), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Show success message if link was sent
                if (_linkSent)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '✓ Verification link sent!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your email (${_emailController.text}) and click the link to sign in.',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _linkSent = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Send Another Link'),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_showLoginForm)
                  // Show login form for existing users
                  LoginForm(
                    email: _emailController.text.trim(),
                    onLoginSuccess: () {
                      if (mounted) {
                        context.go('/home');
                      }
                    },
                    onCancel: () {
                      setState(() {
                        _showLoginForm = false;
                        _emailController.clear();
                      });
                    },
                  )
                else if (_showEmailOTPField)
                  // Show email OTP verification field
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Enter the verification code sent to your email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Colors.blue,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We\'ve sent a verification code to ${_emailController.text}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<String>(
                              future:
                                  Future.value(EmailConfig.otpDeliveryMethod),
                              builder: (context, snapshot) {
                                return Text(
                                  'OTP delivery method: ${snapshot.data ?? "Loading..."}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please check your inbox (and spam folder) for the code',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _emailOTPController,
                        hintText: '6-digit code',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.verified_user,
                      ),

                      // Show error message if any
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSendingLink ? null : _verifyEmailOTP,
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
                          child: _isSendingLink
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Cancel button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showEmailOTPField = false;
                            _emailOTPController.clear();
                            final userModel = Provider.of<UserModel>(
                              context,
                              listen: false,
                            );
                            userModel.cancelEmailVerification();
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                else if (_showVerificationCodeField)
                  // Show verification code field
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Enter the verification code sent to your phone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _smsCodeController,
                        hintText: '6-digit code',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.sms,
                      ),

                      // Show error message if any
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              _isVerifyingPhone ? null : _verifyPhoneCode,
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
                          child: _isVerifyingPhone
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text(
                                  'Verify Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Cancel button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showVerificationCodeField = false;
                            final userModel = Provider.of<UserModel>(
                              context,
                              listen: false,
                            );
                            userModel.cancelPhoneVerification();
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      // OR divider
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 0.5),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 0.5),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Social login options - updated to match Zomato's style
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _socialLoginButton(
                              _googleIconUrl,
                              () {
                                // Not implemented in this version
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Social login is not implemented yet.'),
                                    backgroundColor: Color(0xFFE23744),
                                  ),
                                );
                              },
                              true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _socialLoginButton(
                              _facebookIconUrl,
                              () {
                                // Not implemented in this version
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Social login is not implemented yet.'),
                                    backgroundColor: Color(0xFFE23744),
                                  ),
                                );
                              },
                              false,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Terms and conditions text
                      const Center(
                        child: Text(
                          'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String title, bool isEmail) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _isEmailSelected = isEmail;
            _checkIfButtonEnabled();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: _isEmailSelected == isEmail
                ? const Color(0xFFE23744).withOpacity(0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: _isEmailSelected == isEmail
                    ? const Color(0xFFE23744)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isEmailSelected == isEmail
                    ? const Color(0xFFE23744)
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required IconData prefixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE23744),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _socialLoginButton(String icon, Function() onTap, bool isGoogle) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNetworkImage(
                icon,
                height: 24,
                fallbackIcon: isGoogle ? Icons.g_mobiledata : Icons.facebook,
              ),
              if (isGoogle)
                const SizedBox(
                  width: 8,
                ),
              if (isGoogle)
                const Text(
                  'Google',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // New method to handle network images with error handling
  Widget _buildNetworkImage(
    String url, {
    double? height,
    double? width,
    required IconData fallbackIcon,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: BoxFit.contain,
      placeholder: (context, url) => SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE23744),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        fallbackIcon,
        size: height ?? 24,
        color: const Color(0xFFE23744),
      ),
    );
  }
}
