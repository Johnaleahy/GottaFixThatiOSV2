# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GottaFixThat is an iOS application for tracking and managing fixes, repairs, and maintenance tasks. Built with SwiftUI and SwiftData for iOS 18.2+.

## Common Development Commands

### Build and Run
```bash
# Open project in Xcode
open GottaFixThat.xcodeproj

# Build from command line
xcodebuild -project GottaFixThat.xcodeproj -scheme GottaFixThat -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run tests
xcodebuild test -project GottaFixThat.xcodeproj -scheme GottaFixThat -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Running Individual Tests
```bash
# Run specific test class
xcodebuild test -project GottaFixThat.xcodeproj -scheme GottaFixThat -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:GottaFixThatTests/GottaFixThatTests

# Run UI tests
xcodebuild test -project GottaFixThat.xcodeproj -scheme GottaFixThat -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:GottaFixThatUITests
```

## Architecture

### MVVM Architecture Pattern
The app follows **MVVM (Model-View-ViewModel)** architecture with a **Service-Based** approach optimized for SwiftUI and SwiftData:

- **Models**: Data structures using SwiftData's @Model macro
- **Views**: SwiftUI views with @Query for reactive data binding
- **Services**: Business logic and data operations layer
- **Utilities**: Extensions, helpers, and constants

### Data Flow Pattern
The app uses SwiftUI with SwiftData for reactive data management:

1. **App/GottaFixThatApp.swift** - App entry point, initializes SwiftData ModelContainer
2. **Views/Main/ContentView.swift** - Main UI using NavigationSplitView for master-detail layout
3. **Models/Item.swift** - Core data model using @Model for persistence
4. **Services**: Handle complex business logic and data operations (to be implemented)

### SwiftData Integration
- ModelContainer initialized in app with schema: `[Item.self]`
- Data persisted to disk (not in-memory)
- ContentView accesses data via:
  - `@Environment(\.modelContext)` for mutations
  - `@Query` for automatic data fetching and UI updates

### UI Structure
- Master-detail pattern using NavigationSplitView
- List view shows all items with timestamps
- Detail view currently placeholder ("Select an item")
- Toolbar with Add/Edit functionality

### Key Patterns
- **Property Wrappers**: @main, @Model, @Query, @Environment for dependency injection
- **Reactive Updates**: @Query automatically refreshes UI on data changes
- **CRUD Operations**: All handled through modelContext (insert, delete)

## File Locations

### Project Structure (MVVM)
```
GottaFixThat/
├── App/
│   └── GottaFixThatApp.swift - App entry point
├── Models/
│   └── Item.swift - Data models with @Model
├── Views/
│   ├── Main/
│   │   └── ContentView.swift - Main navigation view
│   ├── List/ - List-related views
│   ├── Detail/ - Detail views
│   └── Components/ - Reusable UI components
├── Services/ - Business logic and data operations
├── Utilities/
│   ├── Extensions/
│   │   └── Color+Extension.swift - Custom colors
│   ├── Helpers/ - Utility functions
│   └── Constants/ - App constants
└── Resources/
    ├── Assets.xcassets/ - Images, colors, app icons
    └── Preview Content/ - Preview assets
```

### Test Files
- `GottaFixThatTests/GottaFixThatTests.swift` - Unit tests (uses Swift Testing framework)
- `GottaFixThatUITests/GottaFixThatUITests.swift` - UI tests
- `GottaFixThatUITests/GottaFixThatUITestsLaunchTests.swift` - Launch performance tests

## Current State

The app is in template/initial development stage with:
- Basic CRUD functionality for items (create, read, delete)
- Each item has only a timestamp property
- NavigationSplitView setup for future detail view implementation
- Test infrastructure present but tests not yet implemented

## Technical Requirements

- **iOS Deployment Target**: 18.2
- **Swift Version**: 5.0
- **Frameworks**: SwiftUI, SwiftData, Foundation
- **Development Team ID**: JHLEUP2UE8