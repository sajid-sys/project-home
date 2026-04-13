# Flutter App Deployment Guide - Project Home Sweet Home

## Table of Contents
1. [GitHub Repository Setup](#github-repository-setup)
2. [GitHub Actions CI/CD](#github-actions-cicd)
3. [Android Deployment](#android-deployment)
4. [iOS Deployment](#ios-deployment)
5. [Continuous Integration](#continuous-integration)

---

## GitHub Repository Setup

### Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com)
2. Click **New** repository
3. Set repository name: `bari_project` (or `Project-Home-Sweet-Home`)
4. Add description: "Home Building Fund Management App"
5. Make it **Private** (if sensitive) or **Public** (for open source)
6. Click **Create repository**

### Step 2: Initialize Local Git Repository

```bash
cd c:\Users\Shahriar Hossen\bari_project

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Project Home Sweet Home app"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/bari_project.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Create `.gitignore`

A `.gitignore` file is already in Flutter projects, but ensure it includes:

```
# Flutter
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
*.iml

# Android
android/.gradle/
android/.idea/
android/local.properties
android/app/release/
android/app/*.jks
android/app/*.keystore

# iOS
ios/.symlinks/
ios/.generated/
ios/Flutter/Flutter.framework/
ios/Flutter/Flutter.podspec

# IDE
.idea/
.vscode/
*.swp
*.swo

# Environment
.env
secrets.json
```

### Step 4: Create `.env` file (for sensitive data)

```
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
KEYSTORE_PASSWORD=your_keystore_password
```

**Important**: Add `.env` to `.gitignore` to prevent pushing sensitive data!

---

## GitHub Actions CI/CD

### How GitHub Actions Works

The workflow file `.github/workflows/flutter_ci.yml` automatically:

1. **Runs on every push** to `main` or `develop` branches
2. **Analyzes code** for errors and warnings
3. **Builds APK** for Android
4. **Builds iOS** app
5. **Creates releases** on GitHub with artifacts

### Workflow Triggers

The workflow runs automatically:
- ✅ On every push to `main` or `develop`
- ✅ On every pull request to `main` or `develop`
- ✅ Creates releases when pushing to `main`

### Monitoring Builds

1. Go to your GitHub repository
2. Click **Actions** tab
3. View build status and logs
4. Download artifacts from completed builds

---

## Android Deployment

### Option 1: Manual Build & Release

```bash
# Build signed APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

### Option 2: Google Play Store Deployment

#### Prerequisites:
1. Google Play Console account ($20 one-time fee)
2. Signed keystore file
3. App signing certificate

#### Create Signing Key:

```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore ~/bari_project.keystore ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias bari_project_key

# Store password securely in GitHub Secrets
```

#### Create GitHub Actions Workflow for Play Store:

Create `.github/workflows/deploy_playstore.yml`:

```yaml
name: Deploy to Google Play Store

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.6'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build & Sign APK
        run: |
          flutter build apk --release \
            --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }}
      
      - name: Upload to Google Play
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.bari.project
          releaseFiles: 'build/app/outputs/flutter-apk/app-release.apk'
          track: beta
```

#### Steps to Deploy:

1. **Create Google Play Console account**
2. **Create app in Play Console**
3. **Generate service account JSON key**:
   - Go to Google Play Console → Settings → API Access
   - Create service account
   - Download JSON file

4. **Add Secrets to GitHub**:
   - Go to repo Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add `PLAY_STORE_SERVICE_ACCOUNT` with JSON content
   - Add `FIREBASE_PROJECT_ID`

5. **Tag a release to trigger deploy**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

---

## iOS Deployment

### Prerequisites:
- Apple Developer Account ($99/year)
- Mac with Xcode
- Signing certificates & provisioning profiles

### Build & Sign for App Store:

```bash
flutter build ios --release

# Requires manual code signing in Xcode
# Or use GitHub Actions with provisioning profiles
```

### GitHub Actions for TestFlight:

Create `.github/workflows/deploy_testflight.yml`:

```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.6'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release
      
      - name: Deploy to TestFlight
        env:
          ASC_USERNAME: ${{ secrets.ASC_USERNAME }}
          ASC_PASSWORD: ${{ secrets.ASC_PASSWORD }}
        run: |
          xcrun altool --upload-app \
            --file "build/ios/ipa/YourApp.ipa" \
            --type ios \
            -u "$ASC_USERNAME" \
            -p "$ASC_PASSWORD"
```

---

## Continuous Integration

### Automated Testing

Add tests to `test/widget_test.dart` and GitHub will automatically run them:

```bash
flutter test --coverage
```

### Code Quality Checks

The workflow includes:
- ✅ `flutter analyze` - Find bugs and issues
- ✅ `flutter test` - Run unit/widget tests
- ✅ Code coverage reports

### Branch Protection Rules

1. Go to repo Settings → Branches
2. Add rule for `main` branch:
   - ✅ Require status checks to pass
   - ✅ Require code reviews before merging
   - ✅ Require branches to be up to date

---

## Setup GitHub Secrets

Required secrets for full automation:

1. **Navigate** to: Settings → Secrets and variables → Actions
2. **Add these secrets**:

| Secret Name | Value |
|---|---|
| `FIREBASE_PROJECT_ID` | Your Firebase project ID |
| `FIREBASE_API_KEY` | Firebase API key |
| `PLAY_STORE_SERVICE_ACCOUNT` | Google Play JSON credentials |
| `KEYSTORE_PASSWORD` | Android signing password |
| `ASC_USERNAME` | Apple ID email |
| `ASC_PASSWORD` | Apple app-specific password |

---

## Deployment Workflow Summary

### For Android:

```
1. Commit & Push Code
   ↓
2. GitHub Actions runs analyze & tests
   ↓
3. GitHub Actions builds APK
   ↓
4. Tag release (git tag v1.0.0)
   ↓
5. GitHub Actions uploads to Google Play
   ↓
6. ✅ App available on Google Play Store
```

### For iOS:

```
1. Commit & Push Code
   ↓
2. GitHub Actions runs tests on macOS
   ↓
3. GitHub Actions builds .ipa
   ↓
4. Upload to TestFlight/App Store
   ↓
5. ✅ App available on App Store
```

---

## Quick Commands Reference

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/bari_project.git

# Create new branch
git checkout -b feature/new-feature

# Push changes
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# Create pull request on GitHub web interface

# Tag release
git tag v1.0.0
git push origin v1.0.0

# View current configuration
git remote -v
git branch -a
```

---

## Troubleshooting

### Build Fails in GitHub Actions

**Check logs**: Actions → Click failed workflow → View logs

**Common issues**:
- ❌ Flutter SDK not found → Update `flutter-version`
- ❌ Dependencies not installed → Run `flutter pub get`
- ❌ Firebase errors → Check environment variables
- ❌ Signing errors → Verify keystore/certificates

### Push Rejected

```bash
# Pull latest changes first
git pull origin main

# Then push again
git push origin main
```

### Large Files (Git LFS)

If binary files are too large:

```bash
# Install Git LFS
git lfs install

# Track large files
git lfs track "*.ipa"
git add .gitattributes
git commit -m "Add LFS for large files"
```

---

## Advanced: Custom Domain & Auto-Updates

### Firebase App Distribution

Deploy to testers without Play Store:

```yaml
- name: Deploy to Firebase App Distribution
  run: |
    flutter build apk --release
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
      --token "${{ secrets.FIREBASE_TOKEN }}" \
      --release-notes "New build: $(date "+%Y-%m-%d")"
```

---

## Resources

- [Flutter Deployment Docs](https://flutter.dev/docs/deployment)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)

---

**Next Steps:**
1. ✅ Push code to GitHub
2. ✅ Set up GitHub Secrets
3. ✅ Monitor first CI/CD run in Actions tab
4. ✅ Create Google Play Developer account
5. ✅ Deploy first release!
