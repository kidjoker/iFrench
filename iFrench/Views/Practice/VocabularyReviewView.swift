//
//  VocabularyReviewView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct VocabularyReviewView: View {
    // Sample vocabulary data
    private let sampleWords = [
        ("Bonjour", "你好"),
        ("Merci", "谢谢"),
        ("Au revoir", "再见"),
        ("Comment ça va?", "你好吗?"),
        ("Bien", "好的")
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Card showing the vocabulary
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(radius: 5)
                    .frame(height: 220)
                
                VStack(spacing: 20) {
                    Text(sampleWords[currentIndex].0)
                        .font(.system(size: 32, weight: .bold))
                    
                    Divider()
                    
                    Text(sampleWords[currentIndex].1)
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Navigation controls
            HStack(spacing: 40) {
                Button(action: previousWord) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                .disabled(currentIndex == 0)
                .opacity(currentIndex == 0 ? 0.5 : 1.0)
                
                Button(action: nextWord) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                .disabled(currentIndex == sampleWords.count - 1)
                .opacity(currentIndex == sampleWords.count - 1 ? 0.5 : 1.0)
            }
            
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<sampleWords.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("词汇复习")
    }
    
    private func nextWord() {
        if currentIndex < sampleWords.count - 1 {
            currentIndex += 1
        }
    }
    
    private func previousWord() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}

#Preview {
    VocabularyReviewView()
} 