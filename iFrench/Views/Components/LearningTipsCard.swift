//
//  LearningTipsCard.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct LearningTipsCard: View {
    // Sample tips - in a real app, these would be dynamically generated
    let tips = [
        "根据你的学习进度，建议每天复习10个单词",
        "尝试用法语思考日常活动，提高语言应用能力",
        "听法语歌曲是提高听力的好方法"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Text("学习建议")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            }
            
            // Divider
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2))
            
            // Tips list
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 12) {
                    // Bullet point
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18))
                        .padding(.top, 2)
                    
                    // Tip text
                    Text(tip)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            }
            
            // More tips button
            Button(action: {
                // Action to show more tips
            }) {
                HStack {
                    Text("查看更多建议")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 5)
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
}

#Preview {
    LearningTipsCard()
        .padding()
        .background(Color.gray.opacity(0.1))
} 