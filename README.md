# School-Van-Operator-App

## Overview
The **School Van Operator App** is a mobile application designed for school van drivers to manage their routes, verify child boarding and deboarding, and communicate with school administrators and parents in real-time. This app is part of the larger **School Van and Children Tracking System**, which aims to enhance the safety, efficiency, and transparency of school transportation.

Built using **Dart** and **Flutter**, the School Van Operator App provides an intuitive and user-friendly interface for drivers to perform their duties effectively while ensuring the safety and security of the children.

## Key Features
1. **Real-Time Route Navigation**
2. **QR Code Verification for Child Boarding/Deboarding**
3. **Child List Management**
4. **Emergency Alerts**
5. **Trip Management**
6. **Real-Time Communication**

## Technologies Used
- Programming Language: Dart
- Framework: Flutter
- State Management: Provider
- Navigation: Flutter Navigation 2.0
- QR Code Scanning: qr_code_scanner package
- Maps and Location: Google Maps API
- Notifications: Firebase Cloud Messaging (FCM)
- Authentication: Firebase Authentication

## Installation and Setup
**Prerequisites**
- Flutter SDK (v3.0 or higher)
- Dart SDK (v2.17 or higher)
- Android Studio or Xcode (for emulator/simulator setup)
- Firebase project (for notifications and authentication)

**Steps to Run the Project**

1. **Clone the repository<br>**
 `git clone https://github.com/your-username/School-Van-Operator-App.git`<br>
 `cd School-Van-Operator-App`

2. **Install Dependencies<br>**
 `flutter pub get`

3. **Set Up Firebase**
- Create a Firebase project at Firebase Console.
- Add an Android/iOS app to your Firebase project and download the google-services.json (Android) or GoogleService-Info.plist (iOS) file.
- Place the configuration file in the appropriate directory:
- Android: android/app/google-services.json
- iOS: ios/Runner/GoogleService-Info.plist

4. **Configure Google Maps API**
- Obtain a Google Maps API key from the Google Cloud Console.
- Add the API key to the AndroidManifest.xml (Android) and AppDelegate.swift (iOS) files.
 
5. **Run the App**
- Connect a physical device or start an emulator/simulator.
- Run the app using the following command<br>
    `flutter run`

## Usage
1. Log In:

    Enter your credentials to log in to the app.

    The system verifies your identity using Firebase Authentication.

2. View Assigned Route:

    View your assigned route on an interactive map.

    Follow turn-by-turn navigation instructions.

3. Scan QR Codes:

    Scan the QR code of each child during boarding and deboarding.

    The app verifies the child's identity and logs the event.

4. Manage Child List:

    View the list of children assigned to your van.

    Track which children have boarded or deboarded.

5. Start/End Trip:

    Start the trip when the van departs and end it when the trip is complete.

    The app logs trip details for reporting and analysis.

6. Send Emergency Alerts:

    Use the emergency button to send alerts to administrators and parents in critical situations

## Contributing
We welcome contributions to the School Van Operator App! If you'd like to contribute, please follow these steps:
    1. Fork the repository.
    2. Create a new branch for your feature or bugfix.
    3. Commit your changes with clear and descriptive messages.
    4. Submit a pull request, explaining the changes you've made.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments
- Flutter Community for providing an excellent framework for cross-platform development.
- Firebase for backend services like authentication and notifications.
- Google Maps API for real-time navigation and location tracking.

## Contact
For any questions or feedback, please reach out to:<br>
    Mumbere Asingya Joshua<br>
    Email: joshuamumbere71@gmail.com<br>
    GitHub: joshuamumbere<br>
**Thank you for using the School Van Operator App! We hope it enhances the safety and efficiency of school transportation for drivers, parents, and administrators alike. 🚐✨**