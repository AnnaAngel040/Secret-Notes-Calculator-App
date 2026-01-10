# 🔐 Calculator Vault – Secure Notes App

Calculator Vault is a Flutter-based privacy-focused notes application that disguises itself as a simple calculator. Behind the calculator interface lies a secure notes vault, accessible only after authentication.

The app is designed to demonstrate **local authentication, offline-first storage, and clean UI theming**, making it ideal for learning Flutter + Hive or showcasing a practical privacy-oriented app.

---

## ✨ Features

- 🧮 **Calculator-style login screen**
- 🔐 **Authentication gate** using local storage
- 📝 **Create, edit, delete notes**
- 🔍 **Instant search through notes**
- 💾 **Offline-first storage** using Hive
- 🎨 **Custom dark theme (Rosé Pine inspired UI)**
- 🚪 **Logout support**

---

## 🛠️ Tech Stack

- **Flutter** (Dart)
- **Hive & Hive Flutter** – local NoSQL storage
- **Material UI**
- **Stateful Widgets**

---


---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code
- Emulator or physical device

### Run Locally

```bash
git clone https://github.com/your-username/calculator_vault.git
cd calculator_vault
flutter pub get
flutter run

🔒 Data Storage

Notes are stored locally using Hive

No cloud sync (by design)

User session is stored securely in a local auth box

