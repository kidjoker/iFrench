//
//  ContentView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// MARK: - ContentView Definition
/// The main container view for the application after successful authentication.
///
/// This view hosts a `TabView` to navigate between the primary sections:
/// Dashboard, Stats, and Profile.
/// It requires `AuthService` and `AppSettings` from the environment or initialization.
struct ContentView: View {
    /// The shared authentication service, injected via the environment.
    @EnvironmentObject private var authService: AuthService
    /// Observable object holding application settings, passed during initialization.
    @ObservedObject var settings: AppSettings
    /// State variable to keep track of the currently selected tab index.
    @State private var selectedTab: Int = 0 // Default to the first tab (Dashboard)

    /// The body of the content view, constructing the tab-based interface.
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            // Wrap content in NavigationStack for navigation within the tab.
            NavigationStack {
                DashboardView(settings: settings)
            }
            .tabItem {
                Label("主页", systemImage: "house.fill") // Use Label for combined image and text
            }
            .tag(0) // Tag identifies this tab for the selection binding

            // Stats Tab
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("统计", systemImage: "chart.bar.fill")
            }
            .tag(1)

            // Profile Tab
            NavigationStack {
                ProfileView(settings: settings)
            }
            .tabItem {
                Label("我的", systemImage: "person.fill")
            }
            .tag(2)
        }
        // You could add modifiers to the TabView itself if needed,
        // e.g., .accentColor() to tint the selected tab item.
    }
}

// MARK: - ContentView Previews
/// Provides previews for the `ContentView` in Xcode.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create required dependencies for the preview.
        // Using shared AuthService and a new AppSettings instance.
        ContentView(settings: AppSettings())
            .environmentObject(AuthService.shared) // Provide mock or shared service
            // Preview with a specific tab selected:
            // .onAppear { (preview.view as? ContentView)?.selectedTab = 1 } // Example
    }
}