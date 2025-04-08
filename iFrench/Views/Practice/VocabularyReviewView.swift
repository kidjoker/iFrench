//
//  VocabularyReviewView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// MARK: - Data Model
/// Represents a single vocabulary item for review.
struct VocabularyItem: Identifiable {
    let id = UUID() // Conforms to Identifiable
    let french: String
    let chinese: String
}

// MARK: - VocabularyReviewView Definition
/// A view for reviewing vocabulary words using flashcards.
struct VocabularyReviewView: View {
    // Sample vocabulary data - Replace with actual data source
    private let vocabularyItems = [
        VocabularyItem(french: "Bonjour", chinese: "你好"),
        VocabularyItem(french: "Merci", chinese: "谢谢"),
        VocabularyItem(french: "Au revoir", chinese: "再见"),
        VocabularyItem(french: "Comment ça va?", chinese: "你好吗?"),
        VocabularyItem(french: "Bien", chinese: "好的")
    ]

    /// State variable tracking the index of the currently displayed word.
    @State private var currentIndex = 0

    /// Computed property for the current item being displayed.
    private var currentItem: VocabularyItem {
        vocabularyItems[currentIndex]
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Push card towards center

            // Vocabulary Card
            vocabularyCard
                .id(currentItem.id) // Apply ID for transitions
                .transition(.asymmetric( // Define entrance/exit animations
                    insertion: .opacity.combined(with: .offset(x: 50)),
                    removal: .opacity.combined(with: .offset(x: -50))
                ))
                .padding(.horizontal) // Padding around the card

            Spacer() // Push controls towards bottom

            // Navigation Controls
            navigationControls

            // Progress Indicator
            progressIndicator
                .padding(.bottom) // Padding below indicator
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
        .background(Color(.systemGroupedBackground).ignoresSafeArea(.container, edges: .bottom)) // Adaptive background
        .navigationTitle("词汇复习")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.3), value: currentIndex) // Animate changes based on currentIndex
    }

    // MARK: - Subviews

    /// The card displaying the current vocabulary item.
    private var vocabularyCard: some View {
        VStack(spacing: 20) {
            Text(currentItem.french)
                .font(.system(size: 36, weight: .bold)) // Larger French word
                .foregroundColor(.primary)

            Divider() // Separator

            Text(currentItem.chinese)
                .font(.system(size: 28)) // Slightly larger Chinese word
                .foregroundColor(.secondary) // Semantic color
        }
        .padding(30) // More padding inside the card
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220) // Ensure minimum height
        .background(.regularMaterial) // Use adaptive material
        .cornerRadius(16) // Slightly larger radius
        .shadow(color: .primary.opacity(0.08), radius: 8, x: 0, y: 2) // Adaptive shadow
    }

    /// Buttons for navigating to the previous/next word.
    private var navigationControls: some View {
        HStack(spacing: 50) { // Increased spacing
            // Previous Button
            Button(action: previousWord) {
                Image(systemName: "arrow.left.circle.fill")
            }
            .font(.system(size: 45)) // Slightly larger buttons
            .foregroundColor(.accentColor) // Use accent color
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.3 : 1.0) // Visual disabled state

            // Next Button
            Button(action: nextWord) {
                Image(systemName: "arrow.right.circle.fill")
            }
            .font(.system(size: 45))
            .foregroundColor(.accentColor)
            .disabled(currentIndex == vocabularyItems.count - 1)
            .opacity(currentIndex == vocabularyItems.count - 1 ? 0.3 : 1.0)
        }
    }

    /// Dots indicating the current position in the vocabulary list.
    private var progressIndicator: some View {
        HStack(spacing: 10) { // Increased spacing for dots
            ForEach(0..<vocabularyItems.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.accentColor : Color.secondary.opacity(0.3)) // Use accent/secondary
                    .frame(width: 10, height: 10) // Slightly larger dots
                    // Add scale effect for the current dot
                    .scaleEffect(index == currentIndex ? 1.2 : 1.0)
            }
        }
        .padding(.vertical) // Add vertical padding around the dots
    }

    // MARK: - Helper Methods

    /// Navigates to the next word if possible.
    private func nextWord() {
        guard currentIndex < vocabularyItems.count - 1 else { return }
        currentIndex += 1
    }

    /// Navigates to the previous word if possible.
    private func previousWord() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
}

// MARK: - Preview
#Preview {
    // Wrap in NavigationStack for consistent preview context
    NavigationStack {
        VocabularyReviewView()
    }
} 