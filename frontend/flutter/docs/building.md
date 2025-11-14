# Building the Frontend

This document explains how to build the Nanookjaro frontend for different platforms.

## Prerequisites

Before building, ensure you have the following tools installed:

- Flutter SDK 3.0 or higher
- Appropriate platform-specific tools (Android SDK for Android, Xcode for iOS, etc.)

## Getting Started

1. Navigate to the frontend directory:
   ```bash
   cd frontend/flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Building for Different Platforms

### Linux (Primary Target)

```bash
flutter build linux --release
```

The built application will be located at `build/linux/x64/release/bundle/`.

### Windows

```bash
flutter build windows --release
```

The built application will be located at `build/windows/x64/runner/Release/`.

### macOS

```bash
flutter build macos --release
```

The built application will be located at `build/macos/Build/Products/Release/`.

### Web

```bash
flutter build web --release
```

The built application will be located at `build/web/`.

### Android

```bash
flutter build apk --release
```

The built APK will be located at `build/app/outputs/flutter-apk/`.

### iOS

```bash
flutter build ios --release
```

Follow Apple's guidelines for distributing iOS apps.

## Environment Configuration

### Development Environment

For development, you can run the app with:

```bash
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

### Production Environment

For production builds, make sure to:

1. Set the appropriate build mode (`--release`, `--profile`, or `--debug`)
2. Configure signing for mobile platforms
3. Optimize assets for web deployment

## Customizing Builds

### Build Arguments

You can pass custom arguments to the build process:

```bash
flutter build linux --dart-define=APP_ENV=production
```

### Conditional Compilation

Use Dart defines for conditional compilation:

```dart
const isProduction = bool.fromEnvironment('APP_ENV') == 'production';
```

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Run `flutter pub get` to install all dependencies.

2. **Build failures**: Clean the build directory:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Platform-specific issues**: Make sure you have the required platform tools installed.

### Platform-Specific Notes

#### Linux
- Requires GTK development libraries
- Uses system theme integration

#### Windows
- Creates a self-contained executable
- Supports Windows 10 and later

#### macOS
- Requires code signing for distribution
- Follows macOS design guidelines

#### Web
- Can be deployed to any web server
- Uses CanvasKit for better performance

#### Mobile
- Requires platform-specific configuration
- Follows respective platform guidelines