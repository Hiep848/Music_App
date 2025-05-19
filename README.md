# 🎵 Music App

A beautiful and modern Flutter Android application that allows users to browse, play, and manage their favorite music. Built with love for clean UI and smooth performance.
This app is still in developing, stay tune for the final product!

---

## 🚀 Features

- 🎧 Play local or online music
- 🔍 Search by artist, album, or song title
- 🎨 Light / Dark mode support
- 📂 Playlist management
- 🔁 Loop, shuffle, skip, and pause controls
- 🧠 Smooth animations and responsive UI
- 📦 Clean architecture
- 🔐 Firebase Auth integration (if any)

---

## 🛠 Tech Stack

- **Flutter** (UI Framework)
- **Dart** (Language)
- **Bloc** (State management)
- **Just Audio / AudioService** (Music playback)
- **Firebase / Cloudinary** (Backend/Online Storage)

---

## 📂 Project Structure

lib/
├── common/
│ ├── helpers/
│ ├── widgets/
├── core/
│ ├── configs/
│ ├── usecase/
├── data/
│ ├── models/
│ ├── repository/
│ └── sources/
├── domain/
│ ├── entities/
│ ├── repository/
│ ├── usecases/
├── presentation/
│ ├── auth/
│ ├── choose_mode/
│ ├── home/
│ ├── intro/
│ ├── splash/
└── firebase_options.dart
└── main.dart
└── service_locator.dart

