//
//  ProfileView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// MARK: - ProfileView Definition
/// A view displaying the user's profile information, settings, support options, and logout button.
struct ProfileView: View {
    /// The shared authentication service, injected via the environment.
    @EnvironmentObject private var authService: AuthService
    /// Observable object holding application settings.
    @ObservedObject var settings: AppSettings
    // Environment(\.dismiss) is usually not needed here as AuthView handles the switch.

    /// The body of the profile view.
    var body: some View {
        // Use List for a more standard settings appearance, especially on iOS.
        // If you prefer the custom spacing, keep the ScrollView/VStack.
        List {
            Section { // Group profile header visually
                profileHeader
                    .listRowInsets(EdgeInsets()) // Remove default list row padding
                    .listRowBackground(Color.clear) // Make background transparent
            }

            Section("设置") { // Use List sections for settings
                SettingsRow(icon: "person.fill", title: "编辑个人资料", color: .blue)
                SettingsRow(icon: "bell.fill", title: "通知设置", color: .orange)
                SettingsRow(icon: "globe", title: "语言设置", color: .green)
                SettingsRow(icon: "paintbrush.fill", title: "外观设置", color: .purple)
            }

            Section("支持") { // Use List sections for support
                SettingsRow(icon: "questionmark.circle", title: "帮助中心", color: .teal)
                SettingsRow(icon: "envelope.fill", title: "联系我们", color: .cyan) // Adjusted color
                SettingsRow(icon: "lock.fill", title: "隐私政策", color: .gray)
            }

            Section { // Section for the logout button
                logoutButton
                    .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)) // Custom padding
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped) // Apply inset grouped style for modern look
        .navigationTitle("个人资料")
        .navigationBarTitleDisplayMode(.inline) // Consistent title display
    }

    // MARK: - Subviews

    /// Displays the user's avatar, username, and email.
    private var profileHeader: some View {
        HStack(spacing: 15) {
            // Avatar Placeholder
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60) // Slightly smaller avatar
                .foregroundColor(.secondary) // Use semantic color
                .padding(5) // Padding around icon
                .background(.thinMaterial, in: Circle()) // Adaptive background

            // User Info (Username and Email)
            VStack(alignment: .leading, spacing: 4) { // Adjusted spacing
                if let user = authService.currentUser {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.semibold) // Semibold instead of bold
                        .foregroundColor(.primary)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Loading...").font(.title2).fontWeight(.semibold).redacted(reason: .placeholder)
                    Text("...").font(.subheadline).foregroundColor(.secondary).redacted(reason: .placeholder)
                }
            }
            Spacer() // Pushes content to the left
        }
        .padding() // Padding inside the header content
    }

    /// The logout button.
    private var logoutButton: some View {
        Button(role: .destructive) { // Use destructive role for visual cue
            authService.logout()
        } label: {
            HStack {
                Spacer() // Center the content
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("退出登录") // Logout
                    .fontWeight(.semibold)
                Spacer() // Center the content
            }
            // Let the List row handle background/padding for consistency
        }
        // Removed explicit background/padding, rely on List styling
    }
}

// MARK: - SettingsRow Component Definition
/// A reusable view component representing a single row in a settings or profile list.
struct SettingsRow: View {
    var icon: String
    var title: String
    var color: Color

    var body: some View {
        Button {
            // TODO: Implement action (e.g., navigation, modal presentation)
            print("Tapped on \(title)") // Placeholder action
        } label: {
            HStack(spacing: 15) {
                // Icon with colored background
                iconView
                Text(title)
                    .foregroundColor(.primary) // Ensure text is primary color
                Spacer()
                // Chevron is often implicit in List rows, but can be kept if desired
                 Image(systemName: "chevron.right")
                     .font(.system(size: 14, weight: .semibold))
                     .foregroundColor(.secondary.opacity(0.5)) // Subtler chevron
            }
            // Padding is handled by the List cell by default
        }
        .foregroundColor(.primary) // Ensure button label uses primary color by default
    }

    /// The styled icon view for the settings row.
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .medium)) // Slightly adjusted icon size/weight
            .foregroundColor(.white)
            .frame(width: 32, height: 32) // Consistent icon background size
            .background(color, in: RoundedRectangle(cornerRadius: 8)) // Simpler background
    }
}

// MARK: - ProfileView Previews
/// Provides previews for the `ProfileView`.
#Preview {
    // Mock User for preview if currentUser is nil initially
    let mockAuth = AuthService.shared // Or a dedicated mock
    // mockAuth.currentUser = User(id: "1", username: "Preview User", email: "preview@example.com")

    return NavigationStack {
        ProfileView(settings: AppSettings())
            .environmentObject(mockAuth)
    }
}

// --- Assumed User struct (Ensure it exists and matches your model) ---
// struct User {
//     var id: String = UUID().uuidString // Example ID
//     var username: String
//     var email: String
// }
// --- 