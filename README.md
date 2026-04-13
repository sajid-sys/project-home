# 🏠 Project Home Sweet Home

> A modern Flutter app for managing community home building funds (Bari/Samiti funds)

A collaborative home savings and collective fund management application built with Flutter, Firebase, and real-time data synchronization.

---

## ✨ Features

### 📊 **Dashboard**
- Real-time fund collection tracking
- Total contributed amount visualization
- Member contribution grid with individual stats
- Live notification feed
- Goal setting and progress tracking

### 💰 **Deposit Management**
- Add deposits with amount, date, and notes
- Edit existing deposits
- **Delete deposit history** with notifications
- Automatic total calculation
- Success confirmation dialogs

### 📋 **Deposit History**
- View all personal contributions
- Summary cards (this month, largest deposit)
- Sortable transaction list
- Edit/Delete functionality
- Real-time total updates

### 🔐 **Authentication**
- Firebase email/password auth
- "Remember me" functionality with SharedPreferences
- Persistent email storage
- Secure logout

### 🔔 **Real-Time Notifications**
- Deposit added notifications
- Deposit edited notifications
- Deposit deleted notifications
- Member activity tracking

### 🎨 **User Interface**
- Modern Material 3 design
- Smooth page transitions (fade + slide)
- Responsive layouts
- Professional color scheme (Blue #185FA5)
- Shadow effects for depth

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.41.6
- **Language**: Dart 3.11.4
- **Backend**: Firebase (Auth, Firestore, Messaging)
- **Local Storage**: SharedPreferences 2.5.3
- **Notifications**: Flutter Local Notifications 21.0.0
- **UI**: Material 3 Design System

---

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web (experimental)
- ✅ Windows (experimental)
- ✅ macOS (experimental)

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.41.6 ([Installation Guide](https://flutter.dev/docs/get-started/install))
- Dart 3.11.4 (included with Flutter)
- Firebase account
- Android Studio or Xcode

### Installation

1. **Clone Repository**
```bash
git clone https://github.com/YOUR_USERNAME/bari_project.git
cd bari_project
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Create Firebase project: https://firebase.google.com
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place in appropriate directories

4. **Run App**
```bash
flutter run

# Or specific device
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d macos         # macOS
```

---

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point & Firebase init
├── screens/
│   ├── login_screen.dart     # Authentication UI
│   ├── dashboard_screen.dart # Main dashboard
│   ├── add_deposit_screen.dart
│   ├── my_deposits_screen.dart
│   └── notifications_screen.dart
└── widgets/                  # Reusable components

android/   # Android native code
ios/       # iOS native code
test/      # Unit & widget tests
```

---

## 🔄 GitHub Actions CI/CD

Automated workflows for:
- ✅ **Code Analysis**: Flutter analyze on every push
- ✅ **Testing**: Automated unit & widget tests
- ✅ **APK Build**: Android release builds
- ✅ **iOS Build**: iOS app builds
- ✅ **Play Store Deployment**: Automated releases

### Workflow Status
![Build Status](https://github.com/YOUR_USERNAME/bari_project/actions/workflows/flutter_ci.yml/badge.svg)

---

## 📤 Deployment

### Google Play Store

1. Tag a release: `git tag v1.0.0 && git push origin v1.0.0`
2. GitHub Actions automatically:
   - Builds and tests code
   - Creates APK/AppBundle
   - Uploads to Google Play

**Full deployment guide**: See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

### Quick Setup: [GitHub Setup Quick Start](./GITHUB_SETUP_QUICK_START.md)

---

## 🎨 Color Scheme

| Color | Hex | Usage |
|---|---|---|
| Primary | `#185FA5` | Buttons, headers, key elements |
| Background | `#F5F7FA` | App background |
| AppBar | `#F8F9FC` | Subtle app bar |
| Dark Blue | `#0C447C` | Titles, text |
| Accent | `#B8D4E8` | Light text, subtitles |

---

## 📊 Database Schema

### Collections:
- **users**: User profiles & total contributions
- **transactions**: Deposit records
- **notifications**: Real-time activity feed
- **settings**: App-wide settings (goals, etc.)

---

## 🤝 Contributing

1. **Fork** the repository
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open Pull Request**

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter format` before committing
- Run `flutter analyze` to check for issues

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## 📝 Changelog

### v1.0.0 (Current)
- ✅ User authentication with Firebase
- ✅ Deposit management (create, read, update, delete)
- ✅ Real-time fund dashboard
- ✅ Notifications system
- ✅ Smooth page transitions
- ✅ Remember me functionality
- ✅ Responsive design
- ✅ CI/CD with GitHub Actions

---

## 🐛 Known Issues

- None currently! Please report issues via GitHub Issues.

---

## 📞 Support

- 💬 **GitHub Issues**: Report bugs and request features
- 📧 **Email**: [Your contact]
- 📚 **Documentation**: Check [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Documentation](https://flutter.dev)
- [Firebase Integration](https://firebase.flutter.dev)
- [Material 3 Design](https://m3.material.io)
- Community feedback and contributions

---

## 📊 Status

- **Version**: 1.0.0
- **Build**: [![Flutter CI/CD](https://github.com/YOUR_USERNAME/bari_project/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/bari_project/actions)
- **Last Updated**: April 2026
- **Maintenance**: Active ✅

---

**Made with ❤️ for Community Home Building**
