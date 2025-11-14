# Nanookjaro Frontend

A modern Flutter frontend for the Nanookjaro Toolkit, designed specifically for Manjaro/Arch Linux users.

## Features

- Real-time system monitoring dashboard
- Package management integration
- Proxy configuration
- Modern glassmorphism UI
- Cross-platform support (Linux, Windows, macOS, Web)

## Project Structure

```
lib/
├── l10n/                  # Localization files
├── providers/             # Riverpod providers for state management
├── services/              # Business logic and external service integration
├── ui/
│   ├── dialogs/           # Dialog components
│   ├── pages/             # Page components
│   ├── widgets/           # Reusable widget components
│   ├── app_shell.dart     # Main application shell
│   └── app_theme.dart     # Application theme definitions
├── main.dart              # Application entry point
```

## Getting Started

1. Install Flutter SDK (3.0 or higher)
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Building

### Linux
```bash
flutter build linux --release
```

### Windows
```bash
flutter build windows --release
```

### macOS
```bash
flutter build macos --release
```

### Web
```bash
flutter build web --release
```

## Architecture

This frontend follows a modular architecture with clear separation of concerns:

- **UI Layer**: Flutter widgets organized in pages, widgets, and dialogs
- **State Management**: Riverpod for reactive state management
- **Service Layer**: FFI bridge to communicate with the C++ backend
- **Providers**: Centralized state providers for different app features

## FFI Integration

The app communicates with the C++ backend through Dart FFI (Foreign Function Interface). 
The [ffi_bridge.dart](file:///home/polarours/Projects/Personal/Nanookjaro-Toolkit/frontend_flutter/lib/services/ffi_bridge.dart) file handles all communication with the native library.

## Localization

The app supports localization through the `l10n` directory. Add new languages by creating 
appropriate ARB files in this directory.

## Dependencies

Key dependencies include:
- flutter_riverpod: State management
- ffi: Foreign Function Interface for native communication
- google_fonts: Custom font support
- intl: Internationalization support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a pull request