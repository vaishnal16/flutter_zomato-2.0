import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isEmailSelected = true;

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
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Make the gradient more red like Zomato
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              const Color(0xFFE23744).withOpacity(0.3),
              const Color(0xFFE23744).withOpacity(0.1),
              Colors.white,
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
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: '#1 ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE23744),
                        ),
                      ),
                      TextSpan(
                        text: 'Food Delivery App',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                    color: Colors.grey,
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

                const SizedBox(height: 25),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            context.go('/home');
                          }
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
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

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
                    _socialLoginButton(
                      'Continue with Google',
                      _googleIconUrl,
                    ),
                    _socialLoginButton(
                      'Continue with Facebook',
                      _facebookIconUrl,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _socialLoginButton(String name, String iconUrl) {
    return Expanded(
      child: InkWell(
        onTap: () {
          context.go('/home');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNetworkImage(
                iconUrl,
                height: 20,
                width: 20,
                fallbackIcon: name.contains('Google')
                    ? Icons.g_mobiledata
                    : Icons.facebook,
              ),
              const SizedBox(width: 10),
              Text(
                name.split(' ').last,
                style: const TextStyle(
                  fontSize: 14,
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
