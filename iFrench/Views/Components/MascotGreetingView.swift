//
//  MascotGreetingView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct MascotGreetingView: View {
    @Binding var selectedMascot: Mascot
    
    var body: some View {
        HStack(spacing: 15) {
            // Mascot Avatar
            ZStack {
                Circle()
                    .fill(selectedMascot.color.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                getMascotImage()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(selectedMascot.color)
            }
            
            // 欢迎信息
            VStack(alignment: .leading, spacing: 5) {
                Text("你好！")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(getDailyMessage())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        #if os(iOS) || os(visionOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Get appropriate mascot image
    private func getMascotImage() -> Image {
        switch selectedMascot {
        case .frog:
            return Image(systemName: "tortoise.fill")
        case .owl:
            return Image(systemName: "owl")
        case .fox:
            return Image(systemName: "hare.fill")
        }
    }
    
    // Get a random daily message
    private func getDailyMessage() -> String {
        let messages = [
            "今天准备好学习新的法语单词了吗？",
            "继续保持学习热情，你已经进步很多了！",
            "今天是继续提高法语能力的好时机！",
            "每天坚持学习一点，积少成多！",
            "你离精通法语又近了一步！"
        ]
        
        // In a real app, this would be deterministic based on the day
        // For demo purposes, we'll just pick a random one
        return messages.randomElement() ?? messages[0]
    }
}

#Preview {
    MascotGreetingView(selectedMascot: .constant(.frog))
        .padding()
        .background(Color.gray.opacity(0.1))
} 