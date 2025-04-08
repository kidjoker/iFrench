import SwiftUI

// MARK: - StatsView Definition
/// A view displaying the user's learning statistics, including summary cards and links to detailed views.
struct StatsView: View {
    /// The shared authentication service, injected via the environment (though not directly used here, might be needed by subviews).
    @EnvironmentObject private var authService: AuthService
    /// The shared statistics service, providing summary data.
    @StateObject private var statsService = StatsService.shared

    // MARK: - Body
    /// The main content of the statistics view.
    var body: some View {
        ScrollView {
            // Main vertical stack for stats content
            VStack(spacing: 20) {
                // Learning Stats Summary Card
                LearningStatsCard()
                    // LearningStatsCard handles its own internal padding

                // Link to Detailed Statistics (only shown if summary is available)
                if statsService.summary != nil {
                    detailedStatsLink
                } else {
                    // Optional: Placeholder or loading indicator if summary is taking time
                    // ProgressView()
                }
            }
            // Apply padding once to the main container
            .padding(.horizontal)
            .padding(.vertical)
        }
        .navigationTitle("学习统计")
        .navigationBarTitleDisplayMode(.inline) // Consistent title display
        // Consider adding background color if needed for the whole scroll view
        // .background(Color(.systemGroupedBackground)) // Example
    }

    // MARK: - Subviews

    /// A navigation link presenting a preview and leading to the DetailedStatsView.
    private var detailedStatsLink: some View {
        NavigationLink(destination: DetailedStatsView()) {
            // Ensure summary exists (already checked in body, but safer here too)
            if let summary = statsService.summary {
                VStack(alignment: .leading, spacing: 12) {
                    // Header for the link
                    HStack {
                        Text("详细统计")
                            .font(.headline)
                            .foregroundColor(.primary) // Use primary color
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary) // Use semantic color
                            .font(.system(size: 14, weight: .semibold)) // Match ProfileView chevron
                    }

                    // Preview Content (Streak and Completion Rate)
                    HStack {
                        // Streak Days
                        VStack(alignment: .leading) {
                            Text("连续学习")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(summary.streakDays)天")
                                .font(.title3) // Adjusted size slightly
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }

                        Spacer()

                        // Completion Rate
                        VStack(alignment: .trailing) {
                            Text("完成率")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(summary.completionRate))%")
                                .font(.title3) // Adjusted size slightly
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial) // Use adaptive material background
                .cornerRadius(15)
                // Consider a slightly different shadow or none if using material
                // .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 2)
            }
        }
        .buttonStyle(.plain) // Ensure the whole area is tappable without default button style
    }
}

// MARK: - Preview
#Preview {
    // Use NavigationStack for preview consistency
    NavigationStack {
        StatsView()
            .environmentObject(AuthService.shared)
            // Optionally inject a mock StatsService with data for preview
            // .environmentObject(MockStatsService.shared)
    }
}