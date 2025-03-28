//
//  PracticeCard.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct PracticeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow indicator with color
            Image(systemName: "chevron.right")
                .foregroundColor(color.opacity(0.8))
                .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .frame(maxWidth: .infinity)
        #if os(iOS) || os(visionOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 15) {
        PracticeCard(
            title: "发音练习",
            description: "提高你的法语发音",
            icon: "waveform",
            color: .blue
        )
        
        PracticeCard(
            title: "词汇复习",
            description: "巩固你学过的单词",
            icon: "book.fill",
            color: .green
        )
        
        PracticeCard(
            title: "听力练习",
            description: "训练你的法语听力",
            icon: "ear.fill",
            color: .purple
        )
    }
    .padding()
} 