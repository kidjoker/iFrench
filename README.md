# iFrench 🇫🇷

An interactive application designed to help users learn and practice the French language through various exercises, personalized feedback, and engaging features.

## ✨ Features

*   **Authentication:** Secure user login and registration.
*   **Personalized Greetings:** Engaging daily messages from selectable mascots (powered by AI).
*   **Vocabulary Review:** Interactive flashcard system for vocabulary practice.
*   **Pronunciation Practice:** Record and get feedback on your French pronunciation (Note: Current implementation uses simulated feedback).
*   **Listening Comprehension:** Practice with audio exercises, including options to import local audio or from YouTube. Question generation utilizes AI.
*   **Learning Statistics:** Track progress with summary cards and detailed analytics, including trends and breakdowns by topic.
*   **Personalized Recommendations:** Receive tailored exercise suggestions based on performance (powered by AI).
*   **Profile Management:** View and manage user profile details.
*   **Adaptive UI:** Designed with SwiftUI for a modern look and feel, adapting to light/dark mode and different platforms.

## 📸 Screenshots

*(Add screenshots of your app here)*
*   Login Screen
*   Dashboard/Main View (if applicable after restructuring)
*   Vocabulary Review
*   Pronunciation Practice
*   Listening Practice
*   Stats View
*   Recommendations View

## 📱 Platforms

Built with SwiftUI, targeting:
*   iOS
*   macOS
*   visionOS *(Based on platform checks seen in code)*

## 🛠️ Technology Stack

*   **UI:** SwiftUI
*   **Language:** Swift
*   **Audio:** AVFoundation
*   **Charts:** SwiftUI Charts
*   **State Management:** Combine (@StateObject, @ObservedObject, @EnvironmentObject)
*   **Backend/Services (Inferred):**
    *   Google Cloud Speech-to-Text (via `QuestionService`)
    *   DeepSeek AI (for recommendations and question generation)
    *   Firebase Authentication (or similar, based on `AuthService`)
    *   (Add any other backend services used)

## 🚀 Getting Started

### Prerequisites

*   Xcode 15.0 or later
*   Swift 5.9 or later
*   An Apple Developer account (for running on physical devices)
*   Access keys/credentials for integrated services (see Configuration).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd iFrench
    ```
2.  **Open the project in Xcode:**
    ```bash
    open iFrench.xcodeproj
    ```
3.  **Dependencies:** Dependencies should be managed by Swift Package Manager and resolve automatically when Xcode opens the project.

### Configuration ⚠️ IMPORTANT ⚠️

This project requires external service credentials that **must not be committed to Git**.

1.  **Google Cloud Service Account:**
    *   You need a `service-account.json` file from Google Cloud Platform with the Speech-to-Text API enabled.
    *   Place this file **exactly** at this location in your project directory: `iFrench/Keys/service-account.json` (Create the `Keys` directory if it doesn't exist).
    *   **Crucially, ensure this file path is listed in your `.gitignore` file** to prevent accidentally committing sensitive credentials. Add the following line to your `.gitignore` if it's not already there:
        ```gitignore
        iFrench/Keys/service-account.json
        ```
    *   The application likely reads the API key needed for `QuestionService` transcription from this file or a separate configuration mechanism (e.g., a `Configuration.swift` file not shown, potentially reading from environment variables or a plist). Verify how `Configuration.googleCloudApiKey` gets its value.

2.  **DeepSeek AI API Key:**
    *   The `DeepSeekService` likely requires an API key. Determine how this key is provided to the service (e.g., environment variable, configuration file, direct initialization - **avoid hardcoding!**) and configure it accordingly. Ensure this key is also ignored by Git if stored in a file.

3.  **Authentication Backend:**
    *   Configure any necessary settings for your chosen authentication provider (e.g., Firebase project configuration via `GoogleService-Info.plist` if using Firebase). Ensure sensitive configuration files are ignored by Git.

## ▶️ Running the App

1.  Ensure all necessary configuration steps above are completed.
2.  Select a target simulator or connected device in Xcode.
3.  Press the Run button (▶) or use `Cmd+R`.

## 📂 Project Structure (Example)
