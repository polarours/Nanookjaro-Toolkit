# Frontend Architecture

## Overview

The Nanookjaro frontend is built with Flutter and follows a modular architecture pattern with clear separation of concerns. It uses Riverpod for state management and communicates with the C++ backend through FFI (Foreign Function Interface).

## Architecture Layers

```
┌────────────────────────────────────────────────────────┐
│                       UI Layer                         │
│              (Widgets, Pages, Dialogs)                 │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                   State Management                     │
│                    (Riverpod)                          │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                    Service Layer                       │
│              (Business Logic, FFI Bridge)              │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                    Native Backend                      │
│                    (C++ Library)                       │
└────────────────────────────────────────────────────────┘
```

## Directory Structure

### lib/
- **l10n/**: Localization files (ARB format)
- **providers/**: Riverpod providers for state management
- **services/**: Business logic and external service integration
- **ui/**: All UI components
  - **dialogs/**: Dialog components
  - **pages/**: Page/screen components
  - **widgets/**: Reusable widget components
  - **app_shell.dart**: Main application shell
  - **app_theme.dart**: Application theme definitions

## State Management

We use Riverpod for state management with the following patterns:

1. **Providers**: Centralized state containers
2. **Notifiers**: State mutation logic
3. **Consumers**: Widgets that listen to state changes

Example:
```dart
// Provider definition
final counterProvider = StateProvider<int>((ref) => 0);

// Consuming state
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}

// Updating state
ref.read(counterProvider.notifier).state++;
```

## FFI Integration

The FFI bridge handles communication with the C++ backend:

1. **Library Loading**: Dynamic loading of the native library
2. **Function Binding**: Mapping C functions to Dart functions
3. **Memory Management**: Proper allocation and deallocation of native memory
4. **Error Handling**: Converting native errors to Dart exceptions

## UI Components

### Widgets
Reusable visual components that can be composed to build pages.

### Pages
Full-screen components that represent distinct sections of the application.

### Dialogs
Overlay components for user interactions that require immediate attention.

## Theming

The application supports:
- Light and dark themes
- System-aware theme selection
- Consistent color palette and typography

## Localization

Internationalization is handled through:
- ARB files in the `l10n` directory
- Code generation for localization keys
- Runtime locale switching

## Testing

Testing strategies include:
1. **Unit Tests**: Testing individual functions and classes
2. **Widget Tests**: Testing UI components in isolation
3. **Integration Tests**: Testing complete workflows

## Performance Considerations

1. **Widget Rebuilding**: Minimize unnecessary widget rebuilds with proper `watch` usage
2. **Async Operations**: Handle asynchronous operations properly to avoid UI blocking
3. **Memory Management**: Properly dispose of resources and cancel subscriptions