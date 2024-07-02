# Keep Notes App

## Overview
Keep Notes is a sophisticated and user-friendly note-taking app built with Flutter. Designed to offer seamless note management, the app ensures your notes are safely stored whether you are offline or online. It leverages the power of local storage with sqflite and cloud storage with Firebase to provide a robust and reliable experience.

## Key Features

1. **Local Database Storage:**
   - **Offline Mode:** When users are not logged in, notes are securely stored on the local database using sqflite. This ensures that you can continue to create and access notes without an internet connection.

2. **Firebase Authentication:**
   - **Login with Gmail:** The app supports login through Gmail using Firebase Authentication, ensuring a simple and secure login process.

3. **Cloud Storage with Firebase:**
   - **Online Mode:** Once logged in, all notes are synchronized with Firebase, providing access to your notes across multiple devices.
   - **Seamless Syncing:** If the network is disconnected after logging in, notes are temporarily stored locally. Background tasks managed by the WorkManager dependency automatically sync the notes with Firebase when the internet connection is restored.

4. **Background Data Synchronization:**
   - **WorkManager Integration:** The app utilizes WorkManager to handle background tasks, ensuring that data synchronization with Firebase occurs as soon as an internet connection is available, without disrupting the user experience.

5. **Recycle Bin Feature:**
   - **Deleted Notes Management:** A recycle bin feature allows users to recover accidentally deleted notes, providing an additional layer of security for your important information.

## Technologies Used

- **Flutter:** The framework used to build a cross-platform application.
- **sqflite:** A plugin for SQLite, used for local database storage.
- **Firebase:** Used for authentication and cloud storage.
- **WorkManager:** Manages background tasks for data synchronization.

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase account
- Android Studio or VS Code

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/suryakant1534/keep_notes.git
