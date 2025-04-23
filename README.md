# Zomato Clone Flutter Web App with Firebase Authentication

This project is a Zomato clone built with Flutter for web, featuring Firebase Authentication using email link (passwordless) sign-in.

## Features

- Responsive web UI similar to Zomato
- Firebase Authentication (passwordless email link sign-in)
- User profile management
- Firestore database integration
- Caching for better performance

## Project Structure

- `lib/screens/` - All app screens (landing, home, profile, etc.)
- `lib/components/` - Reusable UI components
- `lib/models/` - Data models
- `lib/services/` - Services such as authentication
- `web/` - Web-specific configurations

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- A code editor (VS Code, Android Studio, etc.)
- Firebase account

### Setup

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Follow the setup instructions in `FIREBASE_SETUP_GUIDE.md` to set up your Firebase project

### Firebase Configuration

See the `FIREBASE_SETUP_GUIDE.md` file for detailed instructions on setting up Firebase for this project.

### Running the Application

To run the app in development mode:

```
flutter run -d chrome
```

### Authentication Flow

The app uses Firebase Auth with email link (passwordless) sign-in:

1. User enters their email on the landing page
2. They receive an email with a sign-in link
3. Clicking the link brings them back to the app and authenticates them
4. User data is stored in Firestore

## Additional Information

- All authentication is handled via Firebase Auth
- User data is stored in Firestore's 'users' collection
- The app is designed primarily for web but can be extended to mobile

## Troubleshooting

If you encounter issues:

1. Make sure you've followed the Firebase setup guide
2. Check your Firebase configuration in `firebase_options.dart`
3. Ensure all dependencies are correctly installed

## License

This project is for educational purposes only.
