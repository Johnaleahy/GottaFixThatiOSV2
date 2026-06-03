//
//  IntroView.swift
//  GottaFixThat
//
//  Created on 1/21/26.
//

import SwiftUI
import SwiftData

struct IntroView: View {
    @Query private var users: [User]
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingMainApp = false
    @State private var isShowingWelcomeScreen = false
    @State private var isShowingCamera = false

    var currentUser: User? {
        users.first
    }

    var userName: String {
        currentUser?.name ?? "there"
    }

    var body: some View {
        ZStack {
            // Background image
            Image("WelcomePic")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // Dark overlay for better text visibility
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 30) {
                    // App logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .cornerRadius(35)
                        .shadow(radius: 10)

                    // Personalized welcome message
                    VStack(spacing: 0) {
                        Text("You got this,")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)

                        Text("\(userName)!")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
                    }
                }

                Spacer()
                Spacer()

                // Bottom navigation buttons
                HStack(spacing: 40) {
                    // Add new item button
                    Button(action: {
                        isShowingWelcomeScreen = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blueDark)
                                .frame(width: 80, height: 80)

                            Image(systemName: "plus.square")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.greenAccent)
                        }
                    }

                    // Camera button
                    Button(action: {
                        isShowingCamera = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blueDark)
                                .frame(width: 80, height: 80)

                            Image(systemName: "camera")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.greenAccent)
                        }
                    }

                    // View lists button
                    Button(action: {
                        isShowingMainApp = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blueDark)
                                .frame(width: 80, height: 80)

                            Image(systemName: "list.bullet")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.greenAccent)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $isShowingMainApp) {
            FixAppHeaderView()
        }
        .fullScreenCover(isPresented: $isShowingWelcomeScreen) {
            WelcomeScreen()
        }
        .sheet(isPresented: $isShowingCamera) {
            QuickFixCameraView()
        }
        .onAppear {
            ensureUserExists()
        }
    }

    private func ensureUserExists() {
        if users.isEmpty {
            _ = AppUser.fetchOrCreate(in: modelContext)
            try? modelContext.save()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Properties", systemImage: "house.fill")
                }
                .tag(0)

            QuickAddView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(1)

            AllListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
                .tag(2)
        }
        .tint(.greenAccent)
    }
}

// MARK: - Quick Add View (Placeholder)
struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var properties: [Property]
    @State private var selectedProperty: Property?
    @State private var taskTitle = ""
    @State private var selectedPriority: FixPriority = .medium

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Add Task") {
                    TextField("What needs fixing?", text: $taskTitle)

                    Picker("Property", selection: $selectedProperty) {
                        Text("Select Property").tag(nil as Property?)
                        ForEach(properties) { property in
                            Text(property.name).tag(property as Property?)
                        }
                    }

                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(FixPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Button(action: addQuickTask) {
                        Label("Add Task", systemImage: "plus.circle.fill")
                            .foregroundColor(.greenAccent)
                    }
                    .disabled(taskTitle.isEmpty || selectedProperty == nil)
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func addQuickTask() {
        guard let property = selectedProperty, !taskTitle.isEmpty else { return }

        // Find or create a default list
        let list: FixList
        if let firstList = property.lists.first {
            list = firstList
        } else {
            list = FixList(name: "General", property: property)
            modelContext.insert(list)
        }

        let newItem = FixItem(
            title: taskTitle,
            priority: selectedPriority,
            list: list,
            sortOrder: list.items.count
        )
        modelContext.insert(newItem)

        try? modelContext.save()

        // Reset form
        taskTitle = ""
        selectedPriority = .medium
    }
}

// MARK: - All Lists View (Placeholder)
struct AllListsView: View {
    @Query private var allLists: [FixList]

    var body: some View {
        NavigationStack {
            List {
                ForEach(allLists.sorted(by: { $0.property?.name ?? "" < $1.property?.name ?? "" })) { list in
                    NavigationLink(destination: ListDetailView(list: list)) {
                        VStack(alignment: .leading) {
                            Text(list.name)
                                .font(.headline)
                            HStack {
                                Text(list.property?.name ?? "No Property")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(list.itemCount) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("All Lists")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Logo Badge View
struct LogoBadgeView: View {
    var body: some View {
        ZStack {
            // Green rounded square background
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.greenAccent)
                .frame(width: 180, height: 180)

            HStack(spacing: 15) {
                // Checkboxes on the left
                VStack(spacing: 12) {
                    // Empty checkbox
                    Image(systemName: "square")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    // Checked checkbox
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    // Empty checkbox
                    Image(systemName: "square")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                // Text on the right
                VStack(alignment: .leading, spacing: 2) {
                    Text("GOTTA")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.blueDark)

                    Text("FIX")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.blueDark)

                    Text("THAT!")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.blueDark)
                }
            }
        }
    }
}

#Preview {
    IntroView()
        .modelContainer(for: [User.self, Property.self, FixList.self, FixItem.self, FixPhoto.self], inMemory: true)
}
