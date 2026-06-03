# GottaFixThat Test Plan

## Purpose

This plan defines how to verify the current app behavior and prevent regressions as new features are added.

The project currently has minimal automated coverage. This document is the baseline for:

- manual regression testing
- unit test coverage planning
- UI test coverage planning
- release readiness checks

## Current Product Surface

The plan covers the features that exist in the app today:

- app launch and sample data bootstrap
- intro screen and top-level navigation
- property list screen
- property detail / lists screen
- fix list detail screen
- item editing
- photo add / delete / thumbnail display
- photo markup from item edit flow
- quick-fix camera flow
- dark mode styling in active screens
- SwiftData persistence for current models

## Test Strategy

We should split testing into three layers.

### 1. Smoke Tests

Run on every meaningful change.

- app launches without crash
- sample data appears on first launch
- intro screen renders
- navigation into properties, lists, and items works
- editing and saving a task works

### 2. Regression Tests

Run before merging larger feature work and before release candidates.

- CRUD flows for properties, lists, items, and photos
- persistence across relaunch
- dark mode rendering
- markup flow behavior
- quick-fix camera flow
- interaction edge cases around inline editing and navigation

### 3. Structural Tests

Keep model and logic behavior stable as code evolves.

- model-level unit tests
- view model tests once business logic is extracted from views
- UI automation for main user journeys

## Test Environments

Minimum environments to validate:

- iPhone portrait
- iPad layout if supported by the current screen
- light mode
- dark mode
- first launch with empty store
- relaunch with existing persisted data

If only one environment is available during development, default to:

- iPhone
- light mode for smoke
- dark mode for targeted visual regression checks

## Test Data States

Use these repeatable data setups:

### State A: Fresh Install

- empty persistent store
- app seeds default user and sample data

### State B: Seeded Sample Data

- sample properties, lists, and items present
- photos optional

### State C: User-Modified Data

- renamed property
- renamed list
- completed and incomplete items
- at least one item with photos
- at least one marked-up photo

## Manual Regression Checklist

### A. Launch and Bootstrap

- Launch app on a fresh store.
- Verify a default user is created.
- Verify sample properties and lists appear.
- Relaunch app.
- Verify sample data is not duplicated.

### B. Intro Screen

- Verify intro screen loads without layout issues.
- Verify background image, logo, and action buttons appear.
- Tap lists entry and verify navigation into the main app.
- Tap add entry and verify welcome / next-step flow opens.
- Tap camera entry and verify camera flow opens or the current placeholder appears consistently.

### C. Property Screen

- Verify all properties render.
- Verify property card text, image, chevron, and dark-mode styling are readable.
- Add a property.
- Verify the property persists after relaunch.
- Verify the property is assigned to the default user.

### D. Property Name Editing

- Open a property.
- Tap the property name.
- Edit the name and submit.
- Verify the new name persists.
- Edit the name again and tap elsewhere.
- Verify focus loss saves the new name.
- Edit the name and navigate away.
- Verify the edit is not lost.
- Relaunch app and confirm persistence.

### E. List Screen

- Verify list counts, item counts, and completed counts display correctly.
- Add a list.
- Delete a list.
- Rename a list inline.
- Tap into the list immediately after editing the name.
- Verify the new name is saved.
- Rename a list and leave the screen without opening that list.
- Verify the edit still saves.
- Relaunch app and confirm persistence.

### F. Fix List Detail Screen

- Verify list header values are correct.
- Verify item rows display title, status, priority, due date, time, and photo count correctly.
- Verify square checkbox interaction works.
- Verify tapping a row opens task detail edit.
- Verify inline title editing still works.
- Verify item descriptions do not appear in the list row.

### G. Item Editing

- Edit title, notes, priority, due date, estimated time, and tags.
- Save and verify changes persist.
- Reopen the item and confirm values remain correct.
- Mark an item complete and incomplete.
- Verify completion state and timestamps behave correctly.

### H. Photo Management

- Add one photo to an item.
- Add multiple photos to an item.
- Verify thumbnails appear in the edit sheet.
- Verify list detail shows photo thumbnail / photo count behavior correctly.
- Delete a photo.
- Save and verify deleted photo does not return after relaunch.

### I. Photo Markup

- Open an existing photo from item edit.
- Draw simple markup.
- Save markup.
- Verify the updated image persists.
- Reopen the same photo and confirm markup remains.
- Mark up a newly added photo before saving the sheet.
- Save the item and verify the marked-up image persists.

### J. Quick Fix Camera Flow

- Launch quick-fix camera flow.
- Capture a photo.
- Enter task title.
- Choose a target list.
- Save.
- Verify the new task appears in the selected list with the attached photo.

### K. Dark Mode

- Verify intro, property, list, and item edit screens in dark mode.
- Verify text contrast is readable.
- Verify dark backgrounds use the intended visual direction consistently.
- Verify chevrons, icons, and action buttons remain visible.

### L. Persistence

- Rename a property and list.
- Edit an item.
- Add a photo and markup.
- Force close the app.
- Relaunch.
- Verify all changes persist.

## Automated Coverage Plan

## Unit Tests To Add First

These should be the first real automated tests.

### Model Behavior

- `FixItem.toggleCompletion()`
  - sets `isCompleted`
  - sets `completedAt`
  - updates `updatedAt`

- `FixItem.isOverdue`
  - false with no due date
  - false when completed
  - true when due date is past

- `FixList`
  - `itemCount`
  - `completedCount`
  - `progressPercentage`

- `Property`
  - `itemCount`
  - `completedItemCount`

- `FixPhoto.generateThumbnail()`
  - produces thumbnail data when image data is valid

### Shared App Logic

- `AppUser.fetchOrCreate(in:)`
  - returns existing user if present
  - creates one user if store is empty
  - does not create duplicates

## UI Tests To Add First

These are the highest-value automation targets.

### Smoke UI Tests

- app launches to intro view
- navigating from intro to property list works
- navigating property -> list -> item works

### Editing UI Tests

- property name edit persists
- list name edit persists after leaving screen
- item title edit persists

### Photo UI Tests

- add photo to item
- open markup editor and save

If camera-dependent tests are flaky in CI, provide a launch mode that injects mock photos instead of using real camera capture.

## Release Gate

Before a release or TestFlight build, require:

- smoke test pass
- no launch crash
- property/list/item rename regressions checked
- one photo add flow checked
- one markup flow checked
- dark mode spot check
- persistence spot check across relaunch

## Known Gaps

Current gaps in project coverage:

- no meaningful unit tests yet
- no meaningful UI automation yet
- no CI-backed regression execution
- no dedicated mock data/test data harness
- environment issues currently block reliable local build/test execution in some Xcode paths

## Suggested Next Implementation Order

1. Add unit tests for model behavior and `AppUser.fetchOrCreate`.
2. Add UI smoke tests for launch and navigation.
3. Add regression UI tests for property rename and list rename persistence.
4. Add regression UI tests for item edit and photo markup.
5. Add CI execution once local test environment is stable.

