// Configuration for email sending
// IMPORTANT: In a production environment, you would NEVER store these directly in code
// This is for demonstration purposes only

import 'package:flutter/foundation.dart';

/// Configuration for email services
///
/// This file contains settings for email-based authentication.
/// For production use, replace these values with your actual email service credentials.
class EmailConfig {
  /// Whether to enable actual email sending.
  /// Set to false for development, true for production
  static bool get enableEmailSending => false;

  /// The email address used to send verification emails
  /// For Gmail, make sure to:
  /// 1. Enable "Less secure app access" or
  /// 2. Use an App Password if 2FA is enabled
  static String get senderEmail => "your_email@gmail.com";

  /// Password for the sender email
  /// WARNING: Never commit real passwords to your repository!
  /// For production, use environment variables or secure storage
  static String get senderPassword => "your_password";

  /// Name to show as the sender
  static String get senderName => "Zomato Clone App";

  /// Get OTP delivery method based on environment
  /// In debug mode, will print to console
  /// In release mode, will attempt to send real emails
  static String get otpDeliveryMethod {
    if (kDebugMode) {
      return "Console (check terminal/debug output)";
    } else {
      return enableEmailSending
          ? "Email"
          : "Not configured - check email_config.dart";
    }
  }
}

/* HOW TO SET UP EMAIL SENDING:

WEB PLATFORM LIMITATION:
-----------------------
When running in a web browser, direct SMTP email sending is not supported 
due to browser security restrictions. The app will print the OTP to the 
console instead. In a real production app, you would:

1. Use a backend API or Firebase Cloud Functions to send emails
2. Use an email service with a REST API (like SendGrid, Mailgun)

FOR MOBILE / DESKTOP APPS:
-------------------------
1. Create a Gmail account specifically for your app
2. Set up 2-Step Verification for the account 
   (Go to Google Account > Security > 2-Step Verification)
3. Generate an App Password 
   (Go to Google Account > Security > App Passwords)
4. Use that App Password in the senderPassword field above
5. Set enableEmailSending to true

*/
