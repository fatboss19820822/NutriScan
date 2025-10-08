# NutriScan Documentation

Welcome to the NutriScan documentation! This folder contains all setup guides, implementation details, and helper scripts.

## 📁 Folder Structure

```
Documentation/
├── README.md (this file)
├── Setup/
│   ├── AUTHENTICATION_QUICK_START.md
│   ├── AUTHENTICATION_SETUP.md
│   ├── FIRESTORE_QUICK_START.md
│   ├── FIRESTORE_SETUP.md
│   ├── FIX_FIREBASE_SCOPE_ERRORS.md
│   └── FIX_GOOGLE_SIGNIN.md
├── Guides/
│   ├── IMPLEMENTATION_SUMMARY.md
│   ├── IMPLEMENTATION_COMPLETE.md
│   └── TEST_AUTHENTICATION.md
└── Scripts/
    ├── get_reversed_client_id.sh
    ├── check_packages.sh
    └── nuclear_fix.sh
```

---

## 🚀 Quick Start

### First Time Setup

**Start here:** [`Setup/AUTHENTICATION_QUICK_START.md`](Setup/AUTHENTICATION_QUICK_START.md)

This 5-minute guide covers:
- Firebase Authentication setup
- Email/Password configuration
- Google Sign-In setup

---

## 📚 Documentation Index

### 🔐 Authentication Setup

#### Quick Start (5 minutes)
- **[Authentication Quick Start](Setup/AUTHENTICATION_QUICK_START.md)** ⭐ **START HERE**
  - 5-minute setup guide
  - Essential configuration
  - Quick testing

#### Detailed Setup
- **[Authentication Setup Guide](Setup/AUTHENTICATION_SETUP.md)**
  - Complete Firebase configuration
  - Email/Password authentication
  - Google Sign-In integration
  - Security best practices
  - Troubleshooting guide

#### Testing
- **[Test Authentication](Guides/TEST_AUTHENTICATION.md)**
  - Testing scenarios
  - Multiple users
  - Data separation
  - Password reset

---

### ☁️ Firestore Setup

#### Quick Start (5 minutes)
- **[Firestore Quick Start](Setup/FIRESTORE_QUICK_START.md)** ⭐ **START HERE**
  - Enable Firestore
  - Security rules
  - Quick testing

#### Detailed Setup
- **[Firestore Setup Guide](Setup/FIRESTORE_SETUP.md)**
  - Cloud storage configuration
  - Data structure
  - Security rules explained
  - Real-time sync
  - Offline support
  - Pricing information

---

### 🔧 Troubleshooting

#### Firebase Issues
- **[Fix Firebase Scope Errors](Setup/FIX_FIREBASE_SCOPE_ERRORS.md)**
  - Cannot find 'FirebaseApp'
  - Module import issues
  - Package configuration

#### Google Sign-In Issues
- **[Fix Google Sign-In](Setup/FIX_GOOGLE_SIGNIN.md)**
  - No such module 'GoogleSignIn'
  - Package installation
  - REVERSED_CLIENT_ID setup

---

### 📖 Implementation Details

#### Complete Overview
- **[Implementation Complete](Guides/IMPLEMENTATION_COMPLETE.md)**
  - Full feature list
  - File structure
  - Code statistics
  - Architecture overview

#### Technical Summary
- **[Implementation Summary](Guides/IMPLEMENTATION_SUMMARY.md)**
  - Technical details
  - Code architecture
  - Security implementation
  - Best practices

---

## 🛠️ Helper Scripts

All scripts are located in the [`Scripts/`](Scripts/) folder.

### Available Scripts

#### 1. Get REVERSED_CLIENT_ID
```bash
./Documentation/Scripts/get_reversed_client_id.sh
```
**Purpose:** Extract REVERSED_CLIENT_ID from GoogleService-Info.plist for Google Sign-In configuration.

#### 2. Check Packages
```bash
./Documentation/Scripts/check_packages.sh
```
**Purpose:** Verify Firebase and GoogleSignIn packages are installed correctly.

#### 3. Nuclear Fix
```bash
./Documentation/Scripts/nuclear_fix.sh
```
**Purpose:** Clean all build caches and force Xcode to rebuild (use when things break).

---

## 📋 Setup Checklist

### Authentication Setup
- [ ] Enable Email/Password in Firebase Console
- [ ] Enable Google Sign-In in Firebase Console
- [ ] Download GoogleService-Info.plist
- [ ] Update Info.plist with REVERSED_CLIENT_ID
- [ ] Add Firebase packages to Xcode target
- [ ] Test email signup/login
- [ ] Test Google Sign-In

### Firestore Setup
- [ ] Enable Firestore in Firebase Console
- [ ] Set Firestore location
- [ ] Add security rules
- [ ] Publish security rules
- [ ] Add Firestore packages to Xcode target
- [ ] Test adding entries
- [ ] Verify data in Firebase Console
- [ ] Test data isolation

---

## 🎯 Common Workflows

### Setting Up Authentication
1. Read: `Setup/AUTHENTICATION_QUICK_START.md`
2. Follow 3 steps
3. Run: `./Documentation/Scripts/get_reversed_client_id.sh`
4. Test with `Guides/TEST_AUTHENTICATION.md`

### Setting Up Firestore
1. Read: `Setup/FIRESTORE_QUICK_START.md`
2. Enable Firestore in Console
3. Add security rules
4. Add packages to Xcode
5. Build and test

### Troubleshooting Build Errors
1. Check: `Setup/FIX_FIREBASE_SCOPE_ERRORS.md`
2. Check: `Setup/FIX_GOOGLE_SIGNIN.md`
3. Run: `./Documentation/Scripts/check_packages.sh`
4. If needed: `./Documentation/Scripts/nuclear_fix.sh`

---

## 🔍 Quick Reference

### Firebase Console Links
- **Project:** https://console.firebase.google.com
- **Select:** nutriscan-b274f
- **Authentication:** Authentication → Sign-in method
- **Firestore:** Firestore Database → Data/Rules
- **Usage:** Firestore Database → Usage

### Key Configuration Files
- **Info.plist** - Google Sign-In URL scheme
- **GoogleService-Info.plist** - Firebase configuration
- **Firestore Rules** - Security configuration in Console

### Important Xcode Settings
- **Target:** NutriScan
- **Frameworks:** General → Frameworks, Libraries, and Embedded Content
  - FirebaseAuth
  - FirebaseCore
  - FirebaseFirestore
  - FirebaseFirestoreSwift
  - GoogleSignIn
  - GoogleSignInSwift

---

## 📊 Project Statistics

### Code Files
- **Authentication:** 3 new Swift files (~880 lines)
- **Firestore:** 3 new Swift files (~600 lines)
- **Updated:** 5 existing files

### Documentation
- **Setup Guides:** 6 files
- **Implementation Guides:** 3 files
- **Helper Scripts:** 3 files
- **Total:** 12 documentation files

### Features
- ✅ Email/Password authentication
- ✅ Google Sign-In
- ✅ User-specific data storage
- ✅ Cloud storage (Firestore)
- ✅ Real-time sync
- ✅ Offline support
- ✅ Security rules

---

## 🆘 Getting Help

### If You're Stuck:

1. **Check relevant setup guide** in `Setup/` folder
2. **Run diagnostic script:** `./Documentation/Scripts/check_packages.sh`
3. **Check troubleshooting guides** in `Setup/` folder
4. **Try nuclear fix:** `./Documentation/Scripts/nuclear_fix.sh`
5. **Check Firebase Console** for configuration issues

### Common Issues:
- **Import errors:** See `FIX_FIREBASE_SCOPE_ERRORS.md`
- **Google Sign-In:** See `FIX_GOOGLE_SIGNIN.md`
- **Build failures:** Run `check_packages.sh`
- **Data not syncing:** Check Firestore rules

---

## 📱 App Features

### Current Features:
- 🔐 User authentication (Email + Google)
- ☁️ Cloud data storage (Firestore)
- 📊 Food logging with macros
- 🔍 Search and filter
- 📅 Date navigation
- 👤 User profiles
- 🔒 Data isolation per user
- 📡 Offline support
- 🔄 Real-time sync

### Planned Features:
- 📸 Photo upload
- 📊 Analytics and trends
- 🎯 Goal tracking
- 🔔 Notifications
- 🌐 Social features

---

## 🎓 Learning Resources

### Firebase Documentation
- [Firebase Auth iOS](https://firebase.google.com/docs/auth/ios/start)
- [Google Sign-In](https://firebase.google.com/docs/auth/ios/google-signin)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

### Apple Documentation
- [UIKit](https://developer.apple.com/documentation/uikit)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [Core Data](https://developer.apple.com/documentation/coredata)

---

## 📝 Version History

### v2.0 - Firestore Migration
- ☁️ Migrated to cloud storage
- 🔄 Real-time sync
- 📡 Offline support
- 🔒 Enhanced security rules

### v1.0 - Authentication
- 🔐 Firebase Authentication
- 📧 Email/Password login
- 🔑 Google Sign-In
- 👤 User profiles
- 📊 User-specific data

---

## ✅ Completed Setup

Once you've completed setup, you should have:

- ✅ Firebase project configured
- ✅ Authentication enabled (Email + Google)
- ✅ Firestore enabled with security rules
- ✅ All packages added to Xcode
- ✅ App building without errors
- ✅ Users can sign up/login
- ✅ Data saving to cloud
- ✅ Each user sees only their data

---

## 🎉 Success!

Your NutriScan app is now fully configured with:
- ✅ Firebase Authentication
- ✅ Cloud Storage (Firestore)
- ✅ Secure user data
- ✅ Real-time sync
- ✅ Offline support

**Ready to code!** 🚀

---

*Last Updated: October 8, 2025*  
*NutriScan v2.0 with Firebase*

