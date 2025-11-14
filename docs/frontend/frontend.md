# Nanookjaro Frontend Documentation

## Overview

The Nanookjaro frontend is a Flutter desktop application that provides an intuitive user interface for system monitoring and management. It features a glassmorphism design that distinguishes it from traditional system monitoring tools.

The frontend communicates with the C++ backend through Dart FFI to retrieve system information and perform management operations, ensuring good performance and seamless integration.

## Technology Stack

- **Framework**: Flutter 3.x with Desktop Embedding
- **State Management**: Riverpod for reactive state management
- **UI Components**: Custom widgets with glassmorphism design
- **Internationalization**: Flutter's built-in i18n support with ARB files
- **Platform Channels**: dart:ffi for native communication

## Project Structure

```
frontend/flutter/
├── lib/
│   ├── l10n/                  # Localization files
│   ├── providers/             # Riverpod providers for state management
│   ├── services/              # Business logic and external service integration
│   ├── ui/
│   │   ├── dialogs/           # Dialog components
│   │   ├── pages/             # Page components
│   │   ├── widgets/           # Reusable widget components
│   │   ├── app_shell.dart     # Main application shell
│   │   └── app_theme.dart     # Application theme definitions
│   └── main.dart              # Application entry point
├── assets/                    # Application assets
├── linux/                     # Linux-specific configurations
├── windows/                   # Windows-specific configurations
├── macos/                     # macOS-specific configurations
├── pubspec.yaml               # Flutter project configuration
└── README.md                  # Flutter project documentation
```

## Key Components

### Main Application

The entry point is `main.dart`, which sets up the Flutter application with:

1. **Theme Configuration**
   - Light and dark themes
   - Custom color schemes
   - Typography settings

2. **Localization**
   - Multi-language support
   - Dynamic locale switching

3. **Routing**
   - Single-page application architecture
   - Widget-based navigation

### State Management

The application uses Riverpod for state management with these key providers:

1. **MetricsProvider**
   - Manages system metrics data
   - Handles periodic data refresh
   - Maintains historical data for charts

2. **UpdateProvider**
   - Manages package update information
   - Handles package management operations

### UI Components

#### Glassmorphism Design

The application features a glassmorphism design with:

1. **GlassCard Widget**
   - Frosted glass effect
   - Dynamic hover animations
   - Responsive design

2. **Aurora Background**
   - Animated background with aurora effect
   - Dynamic color transitions

#### Key Pages

1. **Dashboard Page**
   - System overview
   - Real-time metrics
   - Quick action buttons

2. **System Information Pages**
   - Detailed CPU information
   - Memory usage details
   - Disk and filesystem information
   - GPU details
   - Network information

#### Dialogs

1. **Pacman Upgrade Dialog**
   - System upgrade interface
   - Command execution and output display

2. **Proxy Configuration Dialog**
   - Proxy settings management

## FFI Integration

The frontend communicates with the backend through the `NanookjaroBridge` service:

### Key Functions

1. **getSystemSummaryJson()**
   - Retrieves system summary information
   - Returns JSON string from backend

2. **pacmanSyncUpgradeJson()**
   - Initiates system upgrade
   - Returns upgrade results

3. **pacmanListUpdatesJson()**
   - Lists available updates
   - Returns update information

4. **setProxy()**
   - Configures proxy settings
   - Returns configuration status

## Internationalization

The application supports multiple languages through:

1. **ARB Files**
   - Located in `lib/l10n/`
   - Contains translated strings

2. **Code Generation**
   - Automatic generation of localization classes
   - Type-safe access to localized strings

## Development Workflow

### Adding New Features

1. **Create Provider**
   - Define Riverpod provider for new data
   - Implement data fetching logic

2. **Create UI Components**
   - Design and implement new widgets
   - Integrate with existing design system

3. **Connect to Backend**
   - Extend FFI bridge if needed
   - Add new functions to backend if required

### Testing

1. **Unit Tests**
   - Test individual functions and classes
   - Mock external dependencies

2. **Widget Tests**
   - Test UI component behavior
   - Verify layout and interactions

## Build and Deployment

### Building for Different Platforms

1. **Linux**
   ```bash
   flutter build linux
   ```

2. **Windows**
   ```bash
   flutter build windows
   ```

3. **macOS**
   ```bash
   flutter build macos
   ```

