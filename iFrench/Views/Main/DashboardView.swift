//
//  DashboardView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// MARK: - DashboardView Definition
/// The main dashboard screen of the iFrench app.
///
/// Displays a personalized greeting from the selected mascot,
/// and provides navigation links to various practice modes.
struct DashboardView: View {
    /// Observable object holding application settings, including the selected mascot.
    @ObservedObject var settings: AppSettings
    /// State variable to control the appearance animation of the welcome message in the toolbar.
    @State private var showWelcome: Bool = false

    // MARK: - Body
    /// The main content of the dashboard view.
    var body: some View {
        ScrollView {
            // Main vertical stack for dashboard content
            VStack(spacing: 20) { // Consistent spacing between elements
                // Greeting View with the selected Mascot
                MascotGreetingView(selectedMascot: $settings.selectedMascot)

                // Grid of Practice Cards
                practiceCardsGrid
            }
            .padding(.horizontal) // Apply horizontal padding once here
            .padding(.vertical)   // Add vertical padding as well
        }
        .navigationBarTitleDisplayMode(.inline) // Keep navigation bar title area compact
        .toolbar {
            // Use a custom view for the principal toolbar item (center)
            ToolbarItem(placement: .principal) {
                principalToolbarContent
            }
        }
        // Trigger the welcome message animation when the view appears
        .onAppear(perform: animateWelcomeMessage)
    }

    // MARK: - Subviews

    /// A grid layout displaying navigation links to different practice modes.
    private var practiceCardsGrid: some View {
        // Vertical stack for the practice cards
        VStack(spacing: 15) { // Spacing between cards
            // Pronunciation Practice Card
            NavigationLink(destination: PronunciationPracticeView()) {
                PracticeCard(
                    title: "发音练习",
                    description: "提高你的法语发音",
                    icon: "waveform",
                    color: .blue
                )
            }
            .buttonStyle(.plain) // Use plain style for better appearance as tappable cards

            // Vocabulary Review Card
            NavigationLink(destination: VocabularyReviewView()) {
                PracticeCard(
                    title: "词汇复习",
                    description: "巩固你学过的单词",
                    icon: "book.fill",
                    color: .green
                )
            }
            .buttonStyle(.plain)

            // Listening Practice Card
            NavigationLink(destination: ListeningPracticeView()) {
                PracticeCard(
                    title: "听力练习",
                    description: "训练你的法语听力",
                    icon: "ear.fill",
                    color: .purple
                )
            }
            .buttonStyle(.plain)
        }
    }

    /// The content view displayed in the center of the navigation bar (principal toolbar item).
    /// Includes the app icon, app name, and an animated welcome message.
    private var principalToolbarContent: some View {
        HStack(spacing: 8) {
            // App Icon (Ensure "AppIcon" exists in your assets)
            Image("AppIcon")
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Subtle border
                )
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1) // Subtle shadow

            // App Name
            Text("iFrench")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            // Animated Welcome Message ("Bonjour!")
            if showWelcome {
                Text("Bonjour!")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    // Apply animation for appearing/disappearing
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }

    // MARK: - Helper Methods

    /// Performs the animation for the welcome message in the toolbar.
    private func animateWelcomeMessage() {
        // Use a slight delay and a spring animation for a nice effect
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.5)) {
            showWelcome = true
        }
    }
}

// MARK: - DashboardView Previews
/// Provides previews for the `DashboardView`.
#Preview {
    // Use NavigationStack in preview to match actual usage context
    // and provide necessary dependencies.
    NavigationStack {
        DashboardView(settings: AppSettings())
            .environmentObject(AuthService.shared) // Assuming AuthService is needed indirectly
    }
} 