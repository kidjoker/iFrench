import SwiftUI

/// A reusable button styled for use in a tab-like interface.
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    // Use accent color for selected state
    @Environment(\.colorScheme) private var colorScheme

    private var selectedForegroundColor: Color {
        // Determine text color based on accent color contrast (simple check)
        // A more robust solution might involve calculating luminance
        // For now, assume white text works on typical accent colors
        .white
    }

    private var selectedBackgroundColor: Color {
        .accentColor // Use the app's defined accent color
    }

    private var unselectedForegroundColor: Color {
        .secondary // Use standard secondary text color
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular) // Add weight change
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(isSelected ? selectedForegroundColor : unselectedForegroundColor)
                .background(isSelected ? selectedBackgroundColor : Color.clear)
                .cornerRadius(8)
                .contentShape(Rectangle()) // Ensure the whole area is tappable
        }
        .buttonStyle(.plain) // Use plain button style to remove default chrome
        .animation(.easeInOut(duration: 0.2), value: isSelected) // Animate selection change
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 10) {
        TabButton(title: "Selected", isSelected: true, action: {})
        TabButton(title: "Unselected", isSelected: false, action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.1))
    // You might want to set a specific accent color for the preview
    // .accentColor(.purple)
} 