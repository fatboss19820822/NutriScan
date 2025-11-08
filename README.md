# NutriScan

NutriScan is an iOS application developed for FIT3178 Assessment 4. It helps health-conscious users scan packaged foods, log meals, and receive personalised nutrition insights powered by Firebase and the Open Food Facts API.

_Last updated: 8 November 2025_

---

## Contents
- [Overview](#overview)
- [Feature Highlights](#feature-highlights)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Setup & Running](#setup--running)
- [Environment Configuration](#environment-configuration)
- [Testing & QA](#testing--qa)
- [Accessibility & UX Notes](#accessibility--ux-notes)
- [Known Limitations](#known-limitations)
- [Acknowledgements](#acknowledgements)

---

## Overview
NutriScan targets students and young adults who need a fast, mobile-first way to understand nutritional intake. Core goals:
- Eliminate manual data entry via barcode scanning.
- Provide contextual nutrition goals based on profile metrics.
- Support healthy habits with configurable reminders and progress tracking.

## Feature Highlights
- **Barcode Scanning:** Capture nutritional facts by scanning UPC/barcodes (AVFoundation + Open Food Facts API).
- **Nutrition Log:** Persist daily food entries, macronutrient summaries, and trends.
- **Personalised Goals:** Calculate BMI, TDEE, and dynamic meal targets from height, weight, and activity level.
- **Meal Reminders:** Local meal notifications with user-defined schedules and quick toggles.
- **Profile Management:** Firebase-backed profile, Google Sign-In, photo upload/compression.
- **Preferences & Theming:** App-wide theme selection plus default meal windows.
- **Acknowledgements View:** In-app listing of third-party libraries, licenses, and content sources to satisfy compliance.

## Architecture
- **Pattern:** UIKit-based MVC with delegation and closure call-backs for async flows.
- **Data Layer:** Firebase Firestore for persistent storage, FirebaseAuth for identity, Core Data retained for legacy compatibility, and `PreferencesManager` using `UserDefaults`.
- **Networking:** `OpenFoodFactsService` performs REST calls (URLSession), decodes JSON, and caches responses via Firestore where appropriate.
- **Dependency Injection:** Shared managers (`AuthenticationManager`, `NotificationManager`, `FirestoreManager`) expose singleton-style APIs for simplicity; view controllers receive models through direct binding.
- **Offline Support:** Firestore local persistence relies on LevelDB/nanopb (transitive Firebase dependencies).

Diagram (high-level):
```
View Controllers → Managers → Firebase / Services
                        ↘︎ Preferences / NotificationCenter
```

## Technology Stack
- **Language:** Swift 5.10
- **Minimum iOS:** 16.0
- **UI Framework:** UIKit, Auto Layout, Storyboards
- **Packages:** Firebase iOS SDK, Google Sign-In, SwiftProtobuf, Google Promises (handled via Swift Package Manager)
- **Tools:** Xcode 16.4, Git, SwiftLint (local)

## Setup & Running
1. **Clone Repository**
   ```bash
   git clone https://git.infotech.monash.edu/fit3178-lam/nutriscan.git
   cd NutriScan
   ```
2. **Install Dependencies**
   - Open `NutriScan.xcodeproj` in Xcode.
   - Allow Swift Package Manager to resolve Firebase/Google packages (requires internet access).
3. **Configure Firebase**
   - Place your `GoogleService-Info.plist` in `NutriScan/Resources/`.
   - Enable Email/Password and Google authentication providers in the Firebase Console.
   - Create Firestore database (production mode with secure rules recommended).
4. **Run**
   - Select the `NutriScan` target.
   - Choose an iOS 16+ simulator or physical device.
   - `Cmd + R` to build and launch.

## Environment Configuration
| Value | Description |
| ----- | ----------- |
| `GoogleService-Info.plist` | Firebase project credentials (bundle ID `edu.monash.NutriScan`). |
| Firebase Firestore Rules | Ensure read/write security rules match assessment requirements. |
| Open Food Facts API | Public, no key required. Respect usage guidelines at <https://world.openfoodfacts.org/data>. |
| Notification Permissions | App requests when launching to enable meal reminders. |


## Acknowledgements
NutriScan includes or depends on:
- **Firebase iOS SDK** – Authentication, Firestore, analytics utilities. Apache License 2.0.  
  © 2013–2025 The Firebase Authors. <https://github.com/firebase/firebase-ios-sdk>
- **Google Sign-In iOS SDK** – Google OAuth integration (includes AppAuth, GTMSessionFetcher). Apache License 2.0.  
  © 2016–2025 Google LLC. <https://developers.google.com/identity/sign-in/ios>
- **SwiftProtobuf** – Protocol Buffers implementation. Apache License 2.0.  
  © 2014–2025 Apple Inc. and contributors. <https://github.com/apple/swift-protobuf>
- **Google Promises** – Promise utilities used by Firebase components. Apache License 2.0.  
  © 2017–2025 Google LLC. <https://github.com/google/promises>
- **LevelDB** – Firestore local persistence storage. BSD 3-Clause License.  
  © 2011–2025 The LevelDB Authors. <https://github.com/google/leveldb>
- **nanopb** – Lightweight Protocol Buffers encoder/decoder. zlib License.  
  © 2011–2025 Petteri Aimonen. <https://github.com/nanopb/nanopb>
- **Open Food Facts API** – Nutrition dataset powering barcode lookups. Creative Commons Attribution-ShareAlike 4.0.  
  <https://world.openfoodfacts.org/>

