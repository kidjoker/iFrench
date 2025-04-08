import SwiftUI

/// A reusable card view to display a single metric with an icon, value, unit, and description.
struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let description: String
    var tintColor: Color = .blue // Allow customization, default to blue

    var body: some View {
        HStack(spacing: 15) { // Added spacing
            // Icon View
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(tintColor)
                .frame(width: 45, height: 45) // Slightly larger icon area
                .background(tintColor.opacity(0.1))
                .cornerRadius(12) // Slightly larger corner radius

            // Text Content
            VStack(alignment: .leading, spacing: 5) { // Adjusted spacing
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Use semantic color

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2) // Slightly larger value
                        .fontWeight(.semibold) // Semibold might look good
                        .lineLimit(1) // Prevent wrapping
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.medium) // Medium weight for unit
                        .foregroundColor(.secondary) // Use semantic color
                        .lineLimit(1)
                }

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary) // Use semantic color
                    .fixedSize(horizontal: false, vertical: true) // Allow description to wrap
            }
            Spacer() // Pushes content to the left
        }
        .padding()
        .background(backgroundMaterial) // Use adaptive background
        .cornerRadius(15)
        .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 2) // Adjusted shadow
        .accessibilityElement(children: .combine) // Combine elements for accessibility
        .accessibilityLabel("\(title): \(value) \(unit)")
        .accessibilityHint(description)
    }

    /// Provides an adaptive background material based on the OS.
    private var backgroundMaterial: some View {
        #if os(visionOS)
        // On visionOS, a thicker material might look better
        .ultraThickMaterial
        #elseif os(iOS)
        // On iOS, standard system background is usually fine
        Color(UIColor.systemBackground)
        #else
        // On macOS, use window background
        Color(.windowBackgroundColor)
        #endif
    }
}

// MARK: - Preview

#Preview("Steps Example") {
    MetricCard(
        title: "今日步数",
        value: "8,754",
        unit: "步",
        icon: "figure.walk",
        description: "目标: 10,000 步",
        tintColor: .green // Example customization
    )
    .padding()
    .background(Color.gray.opacity(0.1)) // Preview background
}

#Preview("Duration Example") {
    MetricCard(
        title: "学习时长",
        value: "45",
        unit: "分钟",
        icon: "clock.fill",
        description: "上次学习: 昨天",
        tintColor: .orange
    )
    .padding()
    .background(Color.gray.opacity(0.1))
    // .preferredColorScheme(.dark) // Preview in dark mode
} 