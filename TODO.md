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
