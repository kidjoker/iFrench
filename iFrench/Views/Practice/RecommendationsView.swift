import SwiftUI

/// A view displaying personalized exercise recommendations based on learning stats.
struct RecommendationsView: View {
    /// The summary statistics used to generate recommendations.
    let stats: LearningStatsSummary
    /// The service responsible for generating recommendations.
    @StateObject private var deepSeekService = DeepSeekService.shared
    /// State variable holding the fetched recommendations.
    @State private var recommendations: [DeepSeekService.ExerciseRecommendation] = []
    /// State variable to store potential errors during fetching.
    @State private var fetchError: Error?
    /// Environment variable to dismiss the view (typically used when presented modally).
    @Environment(\.dismiss) private var dismiss

    /// The main body of the Recommendations view.
    var body: some View {
        // Use NavigationView for title and toolbar, suitable for modal presentation.
        NavigationView {
            content
                .navigationTitle("学习推荐")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Dismiss button typically placed based on presentation context
                    // For modal: .confirmationAction or .navigationBarTrailing
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { dismiss() }
                    }
                }
                .task { // Use .task for asynchronous operations tied to view lifecycle
                    await fetchRecommendations()
                }
                // Use system background for the main view area
                .background(Color(.systemGroupedBackground).ignoresSafeArea(.container, edges: .bottom))
        }
    }

    // MARK: - Content View
    /// Determines the content to display based on loading/error/data state.
    @ViewBuilder
    private var content: some View {
        if deepSeekService.isProcessing {
            loadingView
        } else if let error = fetchError {
            errorView(error: error)
        } else if recommendations.isEmpty {
            emptyStateView
        } else {
            recommendationsList
        }
    }

    // MARK: - Subviews

    /// View displayed while recommendations are loading.
    private var loadingView: some View {
        VStack { // Center the ProgressView
            Spacer()
            ProgressView("生成推荐中...")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// View displayed if an error occurs during fetching.
    private func errorView(error: Error) -> some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("无法加载推荐")
                .font(.title3.bold())
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("重试") {
                Task { await fetchRecommendations() }
            }
            .buttonStyle(.bordered)
            .padding(.top)
            Spacer()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// View displayed when no recommendations are available.
    private var emptyStateView: some View {
         VStack(spacing: 15) {
             Spacer()
             Image(systemName: "list.star")
                 .font(.system(size: 50))
                 .foregroundColor(.secondary)
             Text("暂无推荐")
                 .font(.title3.bold())
             Text("继续学习以获取个性化建议！")
                 .font(.subheadline)
                 .foregroundColor(.secondary)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal)
             Spacer()
             Spacer()
         }
         .padding()
         .frame(maxWidth: .infinity, maxHeight: .infinity)
     }

    /// Scrollable list displaying the recommendation cards.
    private var recommendationsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) { // Consistent spacing
                // Optional: Add a brief explanation text here if desired
                // Text("根据您的学习情况，我们推荐以下练习：").font(.subheadline).foregroundColor(.secondary)

                ForEach(recommendations, id: \.reason) { recommendation in // Explicitly use 'reason' as ID
                    recommendationCard(for: recommendation)
                }
            }
            .padding() // Padding for the scroll content
        }
    }

    /// Creates a card view for a single recommendation.
    /// - Parameter recommendation: The recommendation data model.
    /// - Returns: A configured view for the recommendation card.
    private func recommendationCard(for recommendation: DeepSeekService.ExerciseRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Card Header: Icon, Type, Difficulty
            HStack {
                // FIXME: Replace placeholder icon with correct logic based on your actual ExerciseType enum
                Image(systemName: "questionmark.circle") // Placeholder icon
                    .foregroundColor(.accentColor) // Use accent color for icon
                    .font(.headline) // Adjust size if needed

                Text(recommendation.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Difficulty Tag (using Capsule shape)
                Text(recommendation.difficulty.rawValue)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(recommendation.difficulty.color.opacity(0.15))
                    .foregroundColor(recommendation.difficulty.color)
                    .clipShape(Capsule()) // Use capsule shape
            }

            // Reason Text
            Text(recommendation.reason)
                .font(.body)
                .foregroundColor(.secondary) // Use secondary for description text

            // Confidence Score
            HStack {
                 Text("推荐度:")
                 ProgressView(value: recommendation.confidence, total: 1.0)
                     .tint(confidenceColor(recommendation.confidence)) // Color based on confidence
                     .frame(height: 6) // Make progress bar thicker
                 Text("\(Int(recommendation.confidence * 100))%")
            }
            .font(.caption)
            .foregroundColor(.secondary) // Use secondary for caption text
        }
        .padding()
        .background(.regularMaterial) // Use adaptive material background
        .cornerRadius(12) // Consistent corner radius
        // Optional: Add a subtle shadow if desired with material background
        // .shadow(color: .primary.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    // MARK: - Helper Methods

    /// Asynchronously fetches recommendations from the service.
    private func fetchRecommendations() async {
        fetchError = nil // Clear previous errors
        // No need to set isProcessing manually if using @StateObject's service property directly
        do {
            // Map the LearningStatsSummary to the structure expected by the service
            let learningStats = LearningStats(
                duration: stats.totalDuration,
                topic: .listening, // Assuming this view is always for 'listening', adjust if needed
                completedItems: stats.completedCourses,
                accuracy: stats.testPassRate / 100.0
            )
            recommendations = try await deepSeekService.getPersonalizedRecommendations(userStats: learningStats)
        } catch {
            print("Failed to get recommendations: \(error)")
            fetchError = error // Store the error to display it
        }
    }

    /// Determines the color for the confidence progress bar.
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case ..<0.6: return .orange
        case ..<0.8: return .yellow
        default: return .green
        }
    }
}

// MARK: - Preview
#Preview {
    // Ensure the actual LearningStatsSummary is accessible
    // Create an instance of the actual LearningStatsSummary for the preview
    let previewStats = LearningStatsSummary(
        // Populate with relevant mock/preview data matching the real struct's properties
        totalDuration: 3600,         // Example: 1 hour
        masteredWords: 520,          // Moved up
        completionRate: 80.0,        // Moved up
        retentionRate: 65.0,         // Moved up
        streakDays: 7,               // Moved up
        averageDailyDuration: 1200,  // Moved up: Example 20 mins
        testPassRate: 75.0,          // Moved down
        completedCourses: 15,        // Moved down
        inProgressCourses: 3,
        topicDistribution: [LearningStatsSummary.TopicDistribution]() // Use correctly typed empty dictionary
        // Add/remove/reorder properties as defined in your ACTUAL LearningStatsSummary struct
    )

    // Assume DeepSeekService and its nested types are defined elsewhere
    // If DeepSeekService makes real network calls, mock it for previews.

    RecommendationsView(stats: previewStats) // Pass the instance of the actual struct
        // Provide mock environment objects if DeepSeekService or its dependencies need them
        // .environmentObject(DeepSeekService.shared) // If using a mock shared instance
}

// Placeholder/Assumed definitions removed as they should exist elsewhere