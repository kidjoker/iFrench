# iFrench - French Learning App

## Project Structure

The iFrench app is organized in a modular structure to improve code organization, maintainability, and separation of concerns.

### Directory Structure

- **Models/** - Data models and business logic
  - `AppSettings.swift` - Application settings model
  - `Mascot.swift` - Mascot enum and related properties
  - `ListeningExercise.swift` - Listening exercise data model
  - `VocabularyWord.swift` - Vocabulary word data model

- **Views/** - User interface components
  - **Components/** - Reusable UI components
    - `PracticeCard.swift` - Card component for practice activities
    - `LearningStatsCard.swift` - Learning statistics card
    - `LearningTipsCard.swift` - Learning tips card
    - `MascotGreetingView.swift` - Mascot greeting view
    - `SectionCard.swift` - Generic section card layout
  - **Dashboard/** - Dashboard-related views
    - `DashboardView.swift` - Main dashboard view
  - **Practice/** - Practice-related views
    - `PronunciationPracticeView.swift` - Pronunciation practice view
  - **Profile/** - Profile-related views
    - `ProfileView.swift` - User profile view
  - `ContentView.swift` - Root view for the app

- **Utils/** - Utility functions and helpers
  - `Imports.swift` - Helper for imports and re-exports

### Current Status

The code has been modularized from a single monolithic file into separate components. Each component is designed to have a single responsibility.

Future improvements:
- Implement proper module imports
- Add tests for key components
- Enhance documentation with proper code comments
