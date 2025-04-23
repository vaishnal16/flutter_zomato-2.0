# Email Setup Guide for OTP Verification

This guide will help you set up email sending to receive OTP verification codes on your email.

## Important Note About Web Platform

When running in a web browser (Flutter Web), direct SMTP email sending **is not supported** due to browser security restrictions. When running on web:

1. The OTP will be printed to the console/terminal
2. You'll need to check the console to get the OTP for testing
3. In a production web app, you would need to:
   - Use a backend API or Firebase Cloud Functions to send emails
   - Use an email service with a REST API (SendGrid, Mailgun, etc.)

## Gmail Setup (For Mobile/Desktop Apps)

If you're running on iOS, Android, Windows, macOS, or Linux platforms, you can use Gmail for sending OTPs:

1. **Create a Gmail Account for Your App**
   - It's recommended to create a separate Gmail account just for sending emails from your app
   - This keeps your personal email separate and secure

2. **Enable 2-Step Verification**
   - Go to your Google Account → Security
   - Enable 2-Step Verification (this is required to generate app passwords)

3. **Generate an App Password**
   - Go to your Google Account → Security → App Passwords
   - Select "App" → "Other (Custom name)" → enter "Zomato Clone"
   - Google will generate a 16-character password
   - **Save this password** - you'll only see it once!

4. **Update the Email Configuration**
   - Open the file `lib/config/email_config.dart`
   - Replace `your_app_email@gmail.com` with your Gmail address
   - Replace `your_app_password` with the App Password you generated
   - Change `enableEmailSending` to `true`

```dart
// Example configuration
class EmailConfig {
  static const String senderEmail = 'zomato.clone.app@gmail.com';
  static const String senderPassword = 'abcd efgh ijkl mnop';  // Your 16-character app password
  static const String senderName = 'Zomato Clone';
  
  static const bool enableEmailSending = true;  // Set to true after adding credentials
}
```

5. **Restart the App**
   - Run `flutter clean` and `flutter pub get`
   - Restart your application

## Alternative Free Email Services (For Mobile/Desktop Apps)

If you prefer not to use Gmail, here are some alternative free email services:

### 1. Mailtrap (Free Developer Plan)
   - Create an account at [Mailtrap.io](https://mailtrap.io)
   - Set up an inbox for testing
   - Get the SMTP credentials
   - Update the code in `lib/services/auth_service.dart` to use Mailtrap:

```dart
// Replace the gmail() call with:
final smtpServer = SmtpServer(
  'smtp.mailtrap.io',
  username: 'your_mailtrap_username',
  password: 'your_mailtrap_password',
  port: 2525,
);
```

### 2. Ethereal Email (Temporary Email Service for Testing)
   - Go to [Ethereal Email](https://ethereal.email/)
   - Create a new account (it's free and instant)
   - Get the SMTP credentials
   - Update the code as shown above but with Ethereal's details

## Using the OTP in Web Apps

Since direct email sending doesn't work in web browsers, here's how to get and use the OTP:

1. Enter your email address in the app
2. Click "Send Email OTP"
3. Open your browser's developer console (F12 or right-click → Inspect → Console)
4. Look for a message that says: **"Since this is a demo, use the OTP shown in the console: XXXXXX"**
5. Copy that OTP and enter it in the app

## Troubleshooting

- **Email not being sent on mobile?**
  - Check your console logs for error messages
  - Verify your credentials are correct
  - Make sure `enableEmailSending` is set to `true`

- **Gmail security issues?**
  - Make sure you're using an App Password, not your regular password
  - Check if your Google Account has any security restrictions

- **Can't find the OTP in console?**
  - Make sure your developer console is open
  - Look for lines with "OTP" or "verification code"
  - Try scrolling up in the console if there are many messages

## Production Considerations

For a production app, consider:

1. Using a backend API (like Firebase Cloud Functions) to send emails
2. Using a transactional email service with a REST API (SendGrid, Mailgun)
3. Storing your credentials securely (not in code)
4. Implementing rate limiting to prevent abuse
5. Adding email templates for better branding 