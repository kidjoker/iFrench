import SwiftUI

/// A compact card view displaying a key statistic with its trend.
struct StatsSummaryCard: View {
    let title: String
    let value: String
    let unit: String
    /// A string describing the trend, e.g., "+5%" or "-10 units".
    let trend: String
    /// Indicates if the trend is considered positive (e.g., increase is good).
    let isPositive: Bool

    // Determine colors based on trend direction
    private var trendColor: Color { isPositive ? .green : .red }
    private var trendIcon: String { isPositive ? "arrow.up.right" : "arrow.down.right" }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // Adjusted spacing
            // Header: Title and Trend Icon
            HStack {
                Text(title)
                    .font(.subheadline) // Slightly larger title
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: trendIcon)
                    .font(.caption.weight(.bold)) // Smaller, bolder icon
                    .foregroundColor(trendColor)
            }

            Spacer(minLength: 4) // Add a bit more space

            // Value and Unit
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title) // Larger value
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4) // Align unit slightly lower
                    .lineLimit(1)
                Spacer() // Push value/unit left
            }

            // Trend Text Indicator
            Text(trend)
                .font(.caption) // Standard caption size
                .fontWeight(.medium)
                .padding(.horizontal, 8) // Slightly more padding
                .padding(.vertical, 3)
                .background(trendColor.opacity(0.15)) // Slightly stronger opacity
                .foregroundColor(trendColor)
                .cornerRadius(6) // Slightly larger radius

        }
        .padding()
        .background(backgroundMaterial) // Use adaptive background
        .cornerRadius(15)
        .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 2) // Adjusted shadow
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(unit)")
        .accessibilityValue("Trend: \(trend), \(isPositive ? "Positive" : "Negative")")
    }

    /// Provides an adaptive background material based on the OS.
    private var backgroundMaterial: some View {
        #if os(visionOS)
        .ultraThickMaterial
        #elseif os(iOS)
        Color(UIColor.systemBackground)
        #else
        Color(.windowBackgroundColor)
        #endif
    }
}

// MARK: - Preview

#Preview("Positive Trend") {
    StatsSummaryCard(
        title: "活跃用户",
        value: "1,250",
        unit: "人",
        trend: "+5.2%",
        isPositive: true
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Negative Trend") {
    StatsSummaryCard(
        title: "加载时间",
        value: "150",
        unit: "ms",
        trend: "-15ms",
        isPositive: false // Lower loading time is good, but trend shows decrease
    )
    .padding()
    .background(Color.gray.opacity(0.1))
    // .preferredColorScheme(.dark)
} 