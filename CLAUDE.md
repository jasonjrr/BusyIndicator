# BusyIndicator Framework Guide

## Overview
BusyIndicator is a lightweight SwiftUI component library providing loading state indicators and busy overlays for user feedback.

## Purpose
- Display loading progress to users
- Provide visual feedback during async operations
- Show activity states during network requests
- Block UI interaction while operations are in progress

## Architecture

### Core Components
**BusyIndicator View**: Main loading indicator component
- Customizable activity indicator
- Optional message/text display
- Modal overlay option
- Dismissable state

### Design Features
- Minimal dependencies (no external deps)
- SwiftUI native implementation
- Light/dark mode support
- Accessible UI patterns

## Usage Patterns

### Basic Usage
```swift
@State var isBusy = false

VStack {
    if isBusy {
        BusyIndicator()
    }
    // ... content
}
```

### With Custom Message
```swift
BusyIndicator(message: "Loading...")
```

### Modal Overlay
```swift
ZStack {
    // main content
    if isBusy {
        BusyIndicator()
            .background(Color.black.opacity(0.5))
    }
}
```

## Integration with KT-Cards

Located in: `Packages/KTCardsFoundation/Package.swift`
- Used in KTCardsApp for showing async operation states
- Common in view screens with data loading
- Used in game session management screens

## Platform Support
- **iOS**: 14+
- **macOS**: 12+
- **Swift**: 5.7+

## No External Dependencies
- Pure SwiftUI implementation
- No third-party dependencies required
- Minimal framework size

## Development Notes
- Component is self-contained
- Can be extended with custom indicators
- Thread-safe for concurrent access
- Supports view state binding

## Android Equivalent
For Android, create equivalent using:
- **Jetpack Compose**: ProgressIndicator, CircularProgressIndicator
- **Material Design**: Loading state components
- Custom composable for modal overlays
- LaunchedEffect for state management

See `KTCardsAndroid` project for implementation.
