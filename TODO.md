# TODO

## GottaFixThat iOS App - Development Roadmap

*Based on app mockups in Examples/Screenshots/*

---

## Phase 1: MVP - Core Data & Basic UI 🏗️

### Data Models
- [ ] Create `Property` model (name, image, isFavorite, itemCount)
- [ ] Create `FixList` model (name, property, icon, itemCount)
- [ ] Create `FixItem` model (title, notes, isCompleted, photos, priority, dueDate)
- [ ] Create `User` model (name, profileImage)
- [ ] Set up SwiftData relationships between models
- [ ] Add sample data for testing

### Navigation Structure
- [ ] Implement NavigationSplitView for iPad support
- [ ] Create tab bar with Home, Add, Lists icons
- [ ] Set up navigation stack for Properties → Lists → Items flow
- [ ] Add back button navigation
- [ ] Implement modal sheet for item details

### Basic CRUD Operations
- [ ] Create new properties
- [ ] Create new lists within properties
- [ ] Add items to lists
- [ ] Mark items as complete/incomplete
- [ ] Delete items, lists, and properties
- [ ] Edit existing items

### Photo Management
- [ ] Integrate camera for photo capture
- [ ] Photo library picker integration
- [ ] Store photos with items
- [ ] Display photo thumbnails in list view
- [ ] Full-screen photo viewer

---

## Phase 2: Enhanced Features ✨

### Rich Item Details
- [ ] Add notes/description field with text editor
- [ ] Implement priority levels (HIGH, MEDIUM, LOW)
- [ ] Add colored tags/categories (e.g., "KITCHEN", "BEDROOM")
- [ ] Time estimation field
- [ ] Due date picker
- [ ] Creation/modification timestamps

### Photo Annotation
- [x] Allow simple image markup
- [ ] Draw on photos (circles, arrows)
- [ ] Add text overlays to photos
- [ ] Multiple photos per item (carousel)
- [ ] Video capture support
- [ ] Photo editing (crop, rotate)

### UI Enhancements
- [ ] Custom app header with logo
- [ ] Card-based property/list views
- [ ] Checkbox animations
- [ ] Pull-to-refresh
- [ ] Swipe actions (delete, edit, share)
- [ ] Empty state illustrations

### Organization Features
- [ ] Sort items by priority, date, name
- [ ] Filter by completion status
- [ ] Search across all items
- [ ] Bulk selection and operations
- [ ] Archive completed items

---

## Phase 3: Collaboration & Intelligence 🤝🤖

### Sharing & Collaboration
- [ ] Share lists with other users
- [ ] User avatars in shared lists
- [ ] Real-time sync with CloudKit
- [ ] Activity feed for shared lists
- [ ] Comments on items

### Smart Features
- [ ] Personalized welcome messages ("Hey Rebecca!")
- [ ] Add AI features and job planning
- [ ] AI task suggestions based on date/season
- [ ] Weather-based recommendations
- [ ] Time estimation calculator for grouped tasks
- [ ] Smart categorization of items

### User Profiles
- [ ] User preferences and settings
- [ ] Profile photo management
- [ ] Notification preferences
- [ ] Theme customization (colors, fonts)

---

## Phase 4: Polish & Production 🎨

### Notifications
- [ ] Set up notifications
- [ ] Local notifications for due items
- [ ] Reminder scheduling
- [ ] Push notifications for shared list updates
- [ ] Notification settings per item

### Performance & Polish
- [ ] App icon and launch screen
- [ ] Onboarding flow for new users
- [ ] Haptic feedback
- [ ] Sound effects
- [ ] Accessibility features (VoiceOver, Dynamic Type)
- [ ] Dark mode support
- [ ] iPad optimized layouts

### Data & Sync
- [ ] iCloud backup and sync
- [ ] Export data (PDF, CSV)
- [ ] Import from other apps
- [ ] Offline mode with sync queue
- [ ] Data migration for updates

### App Store Preparation
- [ ] App Store screenshots
- [ ] App preview video
- [ ] Privacy policy
- [ ] Terms of service
- [ ] TestFlight beta testing
- [ ] App Store listing optimization

---

## Future Enhancements 🚀

### Advanced Features
- [ ] Contractor/vendor management
- [ ] Cost tracking and budgets
- [ ] Receipt photo storage
- [ ] Maintenance schedules
- [ ] Home inventory integration
- [ ] Insurance claim documentation

### Integrations
- [ ] Calendar app integration
- [ ] Reminders app import
- [ ] HomeKit integration
- [ ] Maps for property locations
- [ ] Share to Messages/Mail

### AI/ML Enhancements
- [ ] Image recognition for fix suggestions
- [ ] Predictive task creation
- [ ] Seasonal maintenance reminders
- [ ] Natural language task input
- [ ] Voice commands with Siri

---

## Consistency Follow-Up 🧭

- [ ] Consolidate the duplicate navigation/UI flows so the app uses one shared architecture instead of parallel `ContentView` and `FixAppHeaderView` paths
- [ ] Standardize property creation so all entry points assign the same owner data and use one default-user strategy
- [ ] Apply the shared color palette consistently across views instead of mixing custom RGB values and unrelated system colors
- [ ] Standardize file conventions across the codebase (header format, date format, model/type declaration conventions)

---

## Interface Review Feedback 📄

*From `/Users/johnleahy/Downloads/FIX App Interface Review 2026-02-02 (1).pdf`*

### Intro / Home Entry
- [ ] Make the intro action icons use a consistent visual style and line weight, especially the camera icon

### Property Cards / Header
- [ ] Check the logo centering in the property list header
- [ ] Evaluate increasing the logo size so it feels more prominent than the camera/action area
- [ ] Improve dark mode styling for the property cards by using darker card backgrounds with white or light gray text
- [ ] Clean up dark mode across the reviewed screens so the treatment feels consistent end-to-end

### Property Lists Screen
- [ ] Fix copy and naming issues: `Back Deck Refurb` spelling, duplicated `items` text, and other visible typo regressions
- [ ] Replace the Shed Cleanup icon with something more appropriate, such as a broom
- [ ] Increase the visibility of list row chevrons so navigation affordance is clearer
- [ ] Allow editing of the property name
- [ ] Fix list-name editing so changes are saved reliably even if the user leaves the screen before navigating into the list

### Fix List Detail Screen
- [ ] Match the corner radius of the Kim's Bedroom summary block to the rest of the interface
- [ ] Add support for photo thumbnails on list items
- [ ] Switch task completion controls to square checkboxes to better match the logo language
- [ ] Remove item descriptions from the list screen and keep that content on the dedicated item detail screen
- [ ] Make it more obvious that tapping a task opens details, such as by adding a stronger arrow or affordance

### Dark Mode Direction
- [ ] Review whether dark mode should use black/gray or the brand's dark navy/blue as the primary surface color

### App Icon Review
- [ ] Confirm whether the app icon needs a smaller composition that works cleanly inside circular contexts like Apple Watch
- [ ] Confirm whether Icon Composer / the asset workflow can generate the liquid glass icon variants, and document the required source files if so

---

## Code Review Findings 🔍

*From automated code review - January 2025*

### High Priority
- [ ] Fix silent error handling - Replace `try? modelContext.save()` with proper error handling
- [ ] Consolidate duplicate user creation logic (ContentView creates "User", IntroView creates "Rebecca")
- [ ] Extract business logic from Views into ViewModels (MVVM violation)
  - [ ] Create `ContentViewModel` for property management
  - [ ] Create `IntroViewModel` for user management and navigation state
  - [ ] Create `WelcomeScreenViewModel` for task suggestions

### Medium Priority
- [ ] Fix inefficient inline sorting in ForEach loops (ContentView.swift:135, 206)
- [ ] Remove unused code: `LogoBadgeView` struct in IntroView.swift
- [ ] Remove unused state variable: `showingMenu` in WelcomeScreen.swift
- [ ] Split large view files into smaller components:
  - [ ] ContentView.swift (contains 4 view structs)
  - [ ] IntroView.swift (contains 5 view structs)
- [ ] Add `@Query` sort descriptors instead of inline sorting
- [ ] Implement empty `generateThumbnail()` method in FixPhoto.swift or remove it

### Low Priority
- [ ] Add accessibility labels to all interactive elements
- [ ] Replace deprecated `.navigationBarHidden(true)` with `.toolbar(.hidden, for: .navigationBar)`
- [ ] Add confirmation dialogs for destructive delete actions
- [ ] Update Color extension to support 8-character hex (with alpha)
- [ ] Create reusable UI components:
  - [ ] `AddItemButton.swift`
  - [ ] `CheckboxToggle.swift`
  - [ ] `TaskRowView.swift`

---

## Technical Debt & Maintenance 🔧

- [ ] Unit test coverage >80%
- [ ] UI tests for critical flows
- [ ] Performance profiling and optimization
- [ ] Memory leak detection and fixes
- [ ] Code documentation
- [ ] Accessibility audit
- [ ] Security audit
- [ ] Analytics integration
- [ ] Crash reporting setup
- [ ] CI/CD pipeline setup

---

## Current Status
- ✅ Initial project setup
- ✅ Basic SwiftData models (Item only)
- ✅ Navigation structure (NavigationSplitView)
- ✅ App icons and assets
- 🚧 Phase 1 in progress

---

*Last Updated: January 2025*
