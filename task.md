# Task: FoodieFinder App Implementation

- [x] **Phase 1: Backend Setup (Express.js & SQLite)**
  - [x] Initialize Express.js project structure in the `project` folder.
  - [x] Setup SQLite database `users.db` for user accounts.
  - [x] Implement User Registration API endpoint (with `bcrypt` password encryption).
  - [x] Implement Login API endpoint (generating JWT session token).
  - [x] Implement Restaurant Data API endpoint (reading and serving from `export.geojson`).
  - [x] Run and test backend API endpoints locally.

- [x] **Phase 2: Mobile App Initialization (Flutter)**
  - [x] Create new Flutter project (e.g., `foodie_finder`).
  - [x] Configure `pubspec.yaml` with required dependencies (`http`, `flutter_secure_storage`, `local_auth`, `geolocator`, `google_maps_flutter`, `google_generative_ai`, `hive`, `sensors_plus`).
  - [x] Implement base App theme and routing structure.

- [x] **Phase 3: Auth & Session Management (Flutter)**
  - [x] Implement Login/Register UI screen.
  - [x] Integrate API authentication and save JWT using `flutter_secure_storage`.
  - [x] Implement Biometric Login logic using `local_auth`.

- [x] **Phase 4: Core Features, LBS & Search (Flutter)**
  - [x] Implement Main Screen with 3 Bottom Navigation Menus (Home, Search, Profile).
  - [x] Implement Home Screen: LBS Map using `geolocator` and `google_maps_flutter`.
  - [x] Implement Search Screen:
    - [x] Fetch data from Express API (`export.geojson`).
    - [x] Search Bar (by `name` attribute).
    - [x] Filter Chips (by `amenity` and `cuisine` tags).
    - [x] Display distance from user's current location.
  - [x] Implement Profile Screen: Profile info and "Saran & Kesan TPM" Card.

- [x] **Phase 5: Sensors, Minigames, & Extra Features**
  - [x] Implement Accelerometer logic: *Shake-to-Play* triggers Roulette Minigame overlay/popup.
  - [x] Implement Gyroscope logic: Virtual compass on the restaurant detail screen.
  - [x] Implement Currency Conversion and Time Zone (WIB, WIT, WITA, London) on restaurant details.
  - [x] Implement Local Notifications for "Meal Time Reminders".

- [x] **Phase 6: AI/LLM Integration**
  - [x] Integrate Google Gemini API.
  - [x] Create Chatbot/AI Assistant UI for "Asisten Kuliner" to recommend foods.
