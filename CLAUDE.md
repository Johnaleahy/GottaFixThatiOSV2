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

### Data Flow Pattern
The app uses SwiftUI with SwiftData for reactive data management:

1. **GottaFixThatApp.swift** - App entry point, initializes SwiftData ModelContainer
2. **ContentView.swift** - Main UI using NavigationSplitView for master-detail layout
3. **Item.swift** - Core data model using @Model for persistence

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

### Core Application Files
- `GottaFixThat/GottaFixThatApp.swift` - App entry point (32 lines)
- `GottaFixThat/ContentView.swift` - Main UI view (61 lines)
- `GottaFixThat/Item.swift` - Data model (18 lines)

### Test Files
- `GottaFixThatTests/GottaFixThatTests.swift` - Unit tests (uses Swift Testing framework)
- `GottaFixThatUITests/GottaFixThatUITests.swift` - UI tests
- `GottaFixThatUITests/GottaFixThatUITestsLaunchTests.swift` - Launch performance tests

### Assets
- `GottaFixThat/Assets.xcassets/` - Contains app icons, accent color (RGB: 0.643, 0.788, 0.329), and header image

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