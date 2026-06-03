//
//  AppHeaderContainer.swift
//  GottaFixThat
//
//  Created on 1/29/26.
//

import SwiftUI

/// A reusable container view that provides consistent header styling across all navigation views.
/// Displays the green "FixAppHeader" image at the top with the "Fix Logo with Outline" in the toolbar.
struct AppHeaderContainer<Content: View>: View {
    let content: Content
    let showToolbarLogo: Bool

    init(showToolbarLogo: Bool = true, @ViewBuilder content: () -> Content) {
        self.showToolbarLogo = showToolbarLogo
        self.content = content()

        // Make navigation bar transparent so our background shows through
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header image
            Image("FixAppHeader")
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()

            // Content area
            content
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showToolbarLogo {
                ToolbarItem(placement: .principal) {
                    Image("Fix Logo with Outline")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 42)
                        .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppHeaderContainer {
            List {
                Text("Sample content")
                Text("More content")
            }
        }
    }
}
