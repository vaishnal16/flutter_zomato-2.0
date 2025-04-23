# Firebase Setup Guide for Zomato Clone Web App

This guide will help you set up Firebase authentication with email OTP and phone authentication for your Flutter Zomato clone web app.

## 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project"
3. Enter a project name (e.g., "Zomato Clone")
4. Enable Google Analytics if desired
5. Click "Create project"

## 2. Register Your Web App

1. In the Firebase project console, click on the Web icon (</>) to add a web app
2. Enter a nickname for your app (e.g., "Zomato Clone Web")
3. Check "Also set up Firebase Hosting" (optional but recommended)
4. Click "Register app"
5. Copy the Firebase configuration values (you'll need them later)

## 3. Enable Email/Password Authentication

1. In the Firebase console, go to "Authentication" in the left sidebar
2. Click on "Sign-in method"
3. Find "Email/Password" in the list and click on it
4. Enable "Email/Password" (we'll use this for our email OTP system)
5. Save the changes

## 4. Enable Phone Authentication

1. In the Firebase console, go to "Authentication" in the left sidebar
2. Click on "Sign-in method" if not already there
3. Find "Phone" in the list and click on it
4. Toggle the switch to "Enable"
5. Save the changes
6. Note: For testing, you can add test phone numbers in the "Phone numbers for testing" section

## 5. Create Firestore Database

1. In the Firebase console, go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Start in production or test mode (choose according to your needs)
4. Select a location for your database
5. Click "Enable"

## 6. Set Up Firestore Security Rules

1. Go to the "Rules" tab in Firestore Database
2. Update the security rules to allow authenticated users to access their data:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click "Publish"

## 7. Update Your Flutter App Configuration

1. Open `lib/firebase_options.dart` in your project
2. Update the `FirebaseOptions` with the values you copied from the Firebase console:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_AUTH_DOMAIN',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

3. Also update the same values in `web/index.html` inside the `firebaseConfig` object.

## 8. About the OTP Implementation

In this project, we've implemented a custom OTP-based authentication system:

1. For email authentication:
   - We generate a 6-digit OTP code
   - In a real app, you would send this via email using a service like SendGrid or Firebase Functions
   - For demonstration, we display the OTP on the screen
   - When the user enters the correct OTP, we create or sign in the user with Firebase Auth

2. For phone authentication:
   - We use Firebase's built-in phone authentication
   - Firebase sends an SMS with a verification code to the user's phone
   - The user enters this code to verify their phone number

## 9. Running Your App

1. Start your Flutter web app:
```
flutter run -d chrome
```

2. The app should now connect to your Firebase project
3. Test the email OTP system by entering an email address and getting a code
4. Test phone authentication by entering a phone number and the SMS code you receive

## 10. Important Notes for Phone Authentication Testing

1. In development, phone authentication works best with test phone numbers configured in Firebase
2. For web apps, captcha verification is required for phone authentication
3. If testing locally, use Chrome browser for the best experience
4. If you encounter reCAPTCHA issues, make sure your domain is properly allowed in Firebase settings

## 11. Implementing Email Sending in a Production App

For a real production app, you would need to implement actual email sending:

1. Create a Firebase Cloud Function that sends emails with OTPs
2. Use a service like SendGrid, Mailgun, or Amazon SES to send emails
3. Store OTPs securely (e.g., hashed in Firestore with an expiration time)
4. Add rate limiting to prevent abuse

## 12. Troubleshooting

If you encounter any issues:

1. Verify your Firebase configuration values are correct
2. Make sure you've enabled both Email/Password authentication and Phone authentication
3. Check your browser console for any Firebase-related errors
4. Make sure your dependencies are correctly installed with `flutter pub get`

## 13. Next Steps

- Add proper email sending functionality using Firebase Functions
- Implement additional authentication methods like Google or Facebook
- Add more user profile fields to Firestore
- Set up Firebase Hosting for production deployment 