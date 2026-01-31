# 📚 School App

A modern, feature-rich Flutter mobile application designed to enhance the educational experience for students. This app provides essential tools for managing academic life, including study planning, timetable management, past questions access, and authentication features.

## ✨ Features

### 🎯 Core Features
- **Onboarding Experience** - Smooth introduction to the app with an interactive onboarding flow
- **User Authentication** - Secure login and registration with Firebase integration and API support
  - Email/Password authentication
  - Google Sign-In integration
  - API-based authentication service
- **Home Dashboard** - Personalized dashboard with quick access to all features
- **Timetable Management** - Organize and view your class schedule with a calendar interface
- **Study Planner** - Plan and track your study sessions effectively
- **Past Questions** - Access and browse past examination papers by subject

### 🎨 UI/UX Features
- **Light & Dark Mode** - Automatic theme switching based on system preferences
- **Google Fonts Integration** - Beautiful typography with Inter font family
- **Material Design 3** - Modern UI following Material You design principles
- **Responsive Design** - Optimized for various screen sizes

## 🛠️ Technologies & Dependencies

### Core Framework
- **Flutter SDK**: ^3.10.3
- **Dart**: Latest stable version

### Key Dependencies
- `firebase_core` (^3.8.1) - Firebase initialization
- `firebase_auth` (^5.3.3) - Firebase authentication
- `google_sign_in` (^6.2.2) - Google authentication
- `google_fonts` (^6.2.1) - Custom fonts
- `shared_preferences` (^2.3.4) - Local data persistence
- `smooth_page_indicator` (^1.2.0+3) - Onboarding page indicators
- `table_calendar` (^3.1.2) - Calendar functionality
- `http` (^1.2.0) - API networking
- `font_awesome_flutter` (^10.8.0) - Icon library

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.3 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- [Git](https://git-scm.com/)
- An Android or iOS emulator/device for testing

### For iOS Development (macOS only)
- Xcode (latest version)
- CocoaPods

### For Android Development
- Android SDK
- Java Development Kit (JDK)

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd school_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup (Optional but Recommended)
This app supports Firebase authentication. To enable it:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
5. Uncomment the Firebase initialization line in `lib/main.dart`:
   ```dart
   await Firebase.initializeApp();
   ```

### 4. Run the App
```bash
# Run on connected device or emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

### 5. Build the App

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 📁 Project Structure

```
school_app/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── models/                        # Data models
│   │   ├── onboarding_item.dart       # Onboarding slide model
│   │   ├── past_question_document.dart # Past question model
│   │   ├── study_session.dart         # Study session model
│   │   └── timetable_class.dart       # Timetable class model
│   ├── screens/                       # UI screens
│   │   ├── auth/                      # Authentication screens
│   │   │   ├── login_screen.dart      # Login page
│   │   │   └── register_screen.dart   # Registration page
│   │   ├── onboarding/               # Onboarding screens
│   │   │   ├── onboarding_screen.dart # Main onboarding flow
│   │   │   └── onboarding_page.dart   # Individual onboarding page
│   │   ├── home_screen.dart           # Main dashboard
│   │   ├── timetable_screen.dart      # Timetable management
│   │   ├── planner_screen.dart        # Study planner
│   │   └── past_questions_screen.dart # Past questions browser
│   ├── services/                      # Business logic & API services
│   │   ├── auth_service.dart          # Firebase authentication service
│   │   └── api_auth_service.dart      # API-based authentication service
│   └── utils/                         # Utility functions
│       └── onboarding_utils.dart      # Onboarding helper functions
├── android/                           # Android-specific files
├── ios/                               # iOS-specific files
├── web/                               # Web-specific files
├── test/                              # Test files
├── pubspec.yaml                       # Project dependencies
└── README.md                          # This file
```

## 🎨 Theme Configuration

The app supports both light and dark themes that automatically adapt to system preferences:

- **Primary Color**: `#0d59f2` (Blue)
- **Light Background**: `#F5F6F8`
- **Dark Background**: `#101622`
- **Font**: Inter (via Google Fonts)

## 🔑 Authentication

The app provides two authentication methods:

1. **Firebase Authentication** (Default)
   - Email/Password
   - Google Sign-In
   
2. **API Authentication** (Custom Backend)
   - Custom API endpoints
   - Token-based authentication
   - Configurable in `lib/services/api_auth_service.dart`

## 🧪 Testing

Run tests using:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 🐛 Debugging

### Common Issues

#### Firebase initialization error
- Ensure `google-services.json` and `GoogleService-Info.plist` are properly configured
- Uncomment the Firebase initialization line in `main.dart`

#### Dependencies conflict
```bash
flutter clean
flutter pub get
```

#### Build issues
```bash
# Clear build cache
flutter clean

# Rebuild
flutter pub get
flutter run
```

## 📱 Supported Platforms

- ✅ Android (API level 21+)
- ✅ iOS (iOS 12.0+)
- ⚠️ Web (Limited support)
- ⚠️ Windows (Limited support)
- ⚠️ macOS (Limited support)
- ⚠️ Linux (Limited support)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Development

### Code Style
This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints` for static analysis.

### Running Linter
```bash
flutter analyze
```

### Formatting Code
```bash
flutter format .
```

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Review existing documentation

## 🔄 Version History

- **1.0.0+1** - Initial release
  - Onboarding flow
  - Authentication system
  - Home dashboard
  - Timetable management
  - Study planner
  - Past questions access

## 🎯 Roadmap

Future enhancements planned:
- [ ] Push notifications
- [ ] Offline mode support
- [ ] Social features (study groups)
- [ ] Assignment tracking
- [ ] Grade calculator
- [ ] Cloud backup
- [ ] Multi-language support

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

---

**Made with ❤️ using Flutter**



📚 Past Questions Module
Upload Past Questions
Endpoint needed: POST /api/past-questions/upload

json
{
  "file": "multipart/form-data",
  "courseName": "string",
  "courseCode": "string", 
  "semester": "string",
  "level": "string",
  "tags": ["array"],
  "isPaid": "boolean",
  "price": "number"
}
Fetch Past Questions
Endpoint needed: GET /api/past-questions

json
// Response
{
  "questions": [
    {
      "id": "string",
      "title": "string",
      "course": "string",
      "semester": "string",
      "level": "string",
      "downloads": "number",
      "rating": "number",
      "fileUrl": "string",
      "price": "number",
      "tags": ["array"]
    }
  ]
}
Download/Purchase Past Question
Endpoint needed: POST /api/past-questions/:id/download

📰 Campus News Module
Fetch News Articles
Endpoint needed: GET /api/news

json
// Query params: ?category=events&search=exam
// Response
{
  "articles": [
    {
      "id": "string",
      "category": "string",
      "title": "string",
      "description": "string",
      "content": "string",
      "imageUrl": "string",
      "publishedAt": "timestamp",
      "author": "string"
    }
  ]
}
Fetch Single Article
Endpoint needed: GET /api/news/:id

👤 Profile & Wallet Module
Get User Profile
Endpoint needed: GET /api/users/profile

json
{
  "name": "string",
  "email": "string",
  "university": "string",
  "department": "string",
  "level": "string",
  "avatarUrl": "string"
}
Update Profile
Endpoint needed: PUT /api/users/profile

Get Wallet Balance
Endpoint needed: GET /api/wallet/balance

json
{
  "balance": "number",
  "currency": "NGN",
  "earnings": [
    {
      "source": "string",
      "amount": "number",
      "date": "timestamp"
    }
  ]
}
Withdraw Funds
Endpoint needed: POST /api/wallet/withdraw

json
{
  "amount": "number",
  "accountDetails": {
    "bankName": "string",
    "accountNumber": "string"
  }
}
Get Subscription Status
Endpoint needed: GET /api/subscription

json
{
  "plan": "premium",
  "expiresAt": "timestamp",
  "isActive": "boolean"
}
📅 Timetable Module
Get Timetable
Endpoint needed: GET /api/timetable

json
{
  "schedule": [
    {
      "day": "string",
      "time": "string",
      "course": "string",
      "venue": "string",
      "lecturer": "string"
    }
  ]
}
Update Timetable
Endpoint needed: PUT /api/timetable

📝 Planner/Tasks Module
Get Tasks
Endpoint needed: GET /api/tasks

Create Task
Endpoint needed: POST /api/tasks

Update Task
Endpoint needed: PUT /api/tasks/:id

Delete Task
Endpoint needed: DELETE /api/tasks/:id

🏠 Home Screen Analytics
Get Dashboard Stats
Endpoint needed: GET /api/dashboard/stats

json
{
  "studyStreak": "number",
  "tasksCompleted": "number",
  "minutesStudied": "number",
  "upcomingEvents": ["array"]
}
🔔 Notifications
Get Notifications
Endpoint needed: GET /api/notifications

Mark as Read
Endpoint needed: PUT /api/notifications/:id/read

