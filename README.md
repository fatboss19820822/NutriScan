# NutriScan

A modern iOS nutrition tracking app with Firebase authentication and cloud storage.

## 🎯 Features

- 🔐 **Firebase Authentication** (Email + Google Sign-In)
- ☁️ **Cloud Storage** (Firebase Firestore)
- 📊 **Food Logging** with macro tracking
- 🔍 **Search & Filter** by date and name
- 👤 **User Profiles** with personalized data
- 🔒 **Data Privacy** (each user's data is isolated)
- 📡 **Offline Support** (works without internet)
- 🔄 **Real-time Sync** across devices

## 🚀 Quick Start

### Prerequisites
- Xcode 14+ 
- iOS 15.0+
- Firebase account

### Setup (5 Minutes)

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd NutriScan
   ```

2. **Open in Xcode**
   ```bash
   open NutriScan.xcodeproj
   ```

3. **Configure Firebase**
   - Follow [`Documentation/Setup/AUTHENTICATION_QUICK_START.md`](Documentation/Setup/AUTHENTICATION_QUICK_START.md)
   - Enable Authentication (Email + Google)
   - Enable Firestore Database

4. **Add Firebase Packages**
   - In Xcode, add these frameworks to target:
     - FirebaseAuth
     - FirebaseCore
     - FirebaseFirestore
     - FirebaseFirestoreSwift
     - GoogleSignIn
     - GoogleSignInSwift

5. **Build and Run**
   ```
   Cmd + R
   ```

## 📚 Documentation

All documentation is in the [`Documentation/`](Documentation/) folder:

### 📖 Essential Guides
- **[Quick Start Guide](Documentation/Setup/AUTHENTICATION_QUICK_START.md)** - 5-minute setup
- **[Firestore Setup](Documentation/Setup/FIRESTORE_QUICK_START.md)** - Enable cloud storage
- **[Testing Guide](Documentation/Guides/TEST_AUTHENTICATION.md)** - How to test features

### 🔧 Troubleshooting
- **[Fix Firebase Errors](Documentation/Setup/FIX_FIREBASE_SCOPE_ERRORS.md)**
- **[Fix Google Sign-In](Documentation/Setup/FIX_GOOGLE_SIGNIN.md)**

### 🛠️ Helper Scripts
```bash
# Get Google Sign-In configuration
./Documentation/Scripts/get_reversed_client_id.sh

# Check package installation
./Documentation/Scripts/check_packages.sh

# Clean build (when things break)
./Documentation/Scripts/nuclear_fix.sh
```

## 🏗️ Architecture

```
NutriScan/
├── Authentication/
│   ├── AuthenticationManager.swift
│   ├── LoginViewController.swift
│   └── SignUpViewController.swift
├── Data/
│   ├── FirestoreManager.swift
│   ├── FoodEntryModel.swift
│   └── PersistenceController.swift (legacy)
├── Views/
│   ├── FirestoreLogView.swift
│   ├── LogView.swift (legacy)
│   ├── HomeViewController.swift
│   ├── ProfileViewController.swift
│   ├── ScanViewController.swift
│   └── TrendsViewController.swift
└── Resources/
    ├── GoogleService-Info.plist
    └── Info.plist
```

## 🔐 Security

- ✅ Firebase Authentication for user identity
- ✅ Firestore security rules for data access
- ✅ User-specific data isolation
- ✅ Secure password handling (min 6 characters)
- ✅ OAuth 2.0 for Google Sign-In

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /foodEntries/{entryId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == resource.data.userId;
    }
  }
}
```

## 🧪 Testing

### Run Tests
```bash
# Unit tests
Cmd + U

# Manual testing
See Documentation/Guides/TEST_AUTHENTICATION.md
```

### Test Accounts
```
Email: test@example.com
Password: test123456

Email: demo@example.com
Password: demo123456
```

## 📊 Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** UIKit + SwiftUI
- **Architecture:** MVC/MVVM hybrid
- **Backend:** Firebase (Auth + Firestore)
- **Local Storage:** Core Data (legacy)
- **Package Manager:** Swift Package Manager

## 📦 Dependencies

```
firebase-ios-sdk (12.3.0)
├── FirebaseAuth
├── FirebaseCore
├── FirebaseFirestore
└── FirebaseFirestoreSwift

GoogleSignIn-iOS (7.x)
├── GoogleSignIn
└── GoogleSignInSwift
```

## 🛣️ Roadmap

### ✅ Completed
- User authentication (Email + Google)
- Cloud data storage (Firestore)
- Food logging with macros
- User profiles
- Data isolation
- Offline support

### 🔄 In Progress
- Barcode scanning
- Nutritional database integration
- Goals and progress tracking

### 📋 Planned
- Photo upload for meals
- Analytics and trends
- Social features
- Apple Sign-In
- Widget support

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Raymond - *Initial work*

## 🙏 Acknowledgments

- Firebase for backend services
- Google Sign-In for authentication
- SwiftUI for modern UI components

## 📞 Support

For help and troubleshooting:
1. Check [`Documentation/`](Documentation/) folder
2. Review troubleshooting guides
3. Check Firebase Console for errors
4. Run diagnostic scripts

## 🎉 Status

✅ **Production Ready**

- All authentication features working
- Cloud storage operational
- Security rules in place
- Comprehensive documentation
- Helper scripts provided

---

**Made with ❤️ using Swift and Firebase**

*Last Updated: October 8, 2025*

