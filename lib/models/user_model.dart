import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class UserModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String _name = '';
  String _email = '';
  String _phone = '';
  String _profileImageUrl = '';
  List<String> _addresses = [];
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;
  int? _resendToken;
  bool _isPhoneVerificationInProgress = false;
  String? _emailOTP;
  bool _isEmailVerificationInProgress = false;

  // List of past orders (will be fetched from Firestore in a real app)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD12345',
      'date': '12 Jun 2023',
      'restaurant': 'Paradise Biryani',
      'items': ['Veg Biryani x1', 'Butter Naan x2'],
      'amount': 349.0,
      'status': 'Delivered',
    },
    {
      'id': 'ORD12344',
      'date': '10 Jun 2023',
      'restaurant': 'Punjabi Tadka',
      'items': ['Paneer Butter Masala x1', 'Roti x3'],
      'amount': 399.0,
      'status': 'Delivered',
    },
    {
      'id': 'ORD12343',
      'date': '5 Jun 2023',
      'restaurant': 'Pizza Hub',
      'items': ['Margherita Pizza x1', 'Pepsi x1'],
      'amount': 299.0,
      'status': 'Delivered',
    },
  ];

  // Constructor to initialize listener to auth state changes
  UserModel() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _isAuthenticated = true;
        _email = user.email ?? '';
        _name = user.displayName ?? _email.split('@')[0];
        _profileImageUrl = user.photoURL ?? '';

        // Fetch additional user data from Firestore
        await _fetchUserData();
      } else {
        _isAuthenticated = false;
        _email = '';
        _name = '';
        _profileImageUrl = '';
        _phone = '';
        _addresses = [];
      }
      notifyListeners();
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (userData != null) {
        _name = userData['displayName'] ?? '';
        _email = userData['email'] ?? '';
        _profileImageUrl = userData['photoUrl'] ?? '';
        _phone = userData['phone'] ?? '';

        // Convert addresses from Firestore to List<String>
        if (userData['addresses'] != null) {
          _addresses = List<String>.from(userData['addresses']);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Send email OTP
  Future<void> sendEmailOTP(String email) async {
    try {
      _isLoading = true;
      _isEmailVerificationInProgress = true;
      _error = null;
      notifyListeners();

      await _authService.sendEmailOTP(email);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Verify email OTP
  Future<void> verifyEmailOTP(String email, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        await _authService.verifyEmailOTP(email, otp);

        _isEmailVerificationInProgress = false;
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _isLoading = false;

        // For specific error about existing account, we want to preserve the original message
        if (e.toString().contains('already registered') ||
            e.toString().contains('already in use')) {
          _error = e.toString();
          notifyListeners();
          rethrow;
        }

        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cancel email verification
  void cancelEmailVerification() {
    _isEmailVerificationInProgress = false;
    _emailOTP = null;
    notifyListeners();
  }

  // Phone Authentication Methods

  // Start phone verification process
  Future<void> startPhoneVerification(String phoneNumber) async {
    try {
      _isLoading = true;
      _isPhoneVerificationInProgress = true;
      _error = null;
      notifyListeners();

      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        // Auto verification if possible (usually only works on Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        // Handle verification failure
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          _isPhoneVerificationInProgress = false;
          _error = e.message;
          notifyListeners();
        },
        // Handle when code is sent to the device
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
          notifyListeners();
        },
        // Handle timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          _isPhoneVerificationInProgress = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _isPhoneVerificationInProgress = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Verify phone with SMS code
  Future<void> verifyPhoneWithCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw Exception(
            'No verification ID found. Please request a code first.');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithPhoneVerificationCode(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      _isPhoneVerificationInProgress = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Helper method to sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.signInWithCredential(credential);

      _isPhoneVerificationInProgress = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cancel phone verification
  void cancelPhoneVerification() {
    _isPhoneVerificationInProgress = false;
    _verificationId = null;
    _resendToken = null;
    notifyListeners();
  }

  // Sign in with email and password (for existing users)
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Sign in using the auth service
      await _authService.signInWithEmailPassword(email, password);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Sign in with email only (no password) for existing users
  Future<void> signInWithEmailOnly(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Normalize email
      final normalizedEmail = email.trim().toLowerCase();

      try {
        // Try to sign in directly
        await _authService.signInWithEmailOnly(normalizedEmail);

        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _isLoading = false;

        final errorMessage = e.toString();
        print('Error during login: $errorMessage');

        // If email is already registered, treat it as a successful login
        if (errorMessage.contains('already registered') ||
            errorMessage.contains('already in use')) {
          print('Email already exists - treating as successful login');
          // Set user as authenticated
          _isAuthenticated = true;
          _email = normalizedEmail;
          _name = normalizedEmail.split('@')[0];
          notifyListeners();
          return; // Exit without rethrowing
        } else if (errorMessage.contains('User not found') ||
            errorMessage.contains('Account not found')) {
          _error = 'Account not found. Please sign up first.';
        } else if (errorMessage.contains('network')) {
          _error = 'Network error. Please check your internet connection.';
        } else if (errorMessage.contains('password may be different')) {
          _error =
              'This email is registered but with a different password. Please try another email.';
        } else if (errorMessage.contains('admin-restricted-operation')) {
          _error =
              'Login failed due to authentication restrictions. Please try another email address.';
        } else {
          _error = 'Login failed: ${errorMessage.split('Exception: ').last}';
        }

        print('User model login error: $_error');
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update profile
  Future<void> updateProfile(
      {String? name, String? photoURL, String? phone}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateUserProfile(
        displayName: name,
        photoURL: photoURL,
      );

      // Update phone number in Firestore (not in Auth)
      if (phone != null) {
        final user = _authService.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'phone': phone});
          _phone = phone;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Getters
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get profileImageUrl => _profileImageUrl;
  List<String> get addresses => _addresses;
  List<Map<String, dynamic>> get orders => _orders;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPhoneVerificationInProgress => _isPhoneVerificationInProgress;
  bool get isEmailVerificationInProgress => _isEmailVerificationInProgress;

  // Add a new address
  Future<void> addAddress(String address) async {
    final user = _authService.currentUser;
    if (user != null) {
      _addresses.add(address);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'addresses': _addresses});

      notifyListeners();
    }
  }

  // Remove an address
  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _addresses.length) {
      final user = _authService.currentUser;
      if (user != null) {
        _addresses.removeAt(index);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'addresses': _addresses});

        notifyListeners();
      }
    }
  }

  // Update an address
  Future<void> updateAddress(int index, String newAddress) async {
    if (index >= 0 && index < _addresses.length) {
      final user = _authService.currentUser;
      if (user != null) {
        _addresses[index] = newAddress;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'addresses': _addresses});

        notifyListeners();
      }
    }
  }
}
