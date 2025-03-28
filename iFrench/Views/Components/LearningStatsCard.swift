//
//  LearningStatsCard.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct LearningStatsCard: View {
    // Sample data - in a real app, these would be passed in as parameters
    let daysStudied = 5
    let timeSpent = 120
    let wordsLearned = 45
    let weeklyGoalProgress = 0.7
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack {
                Text("学习统计")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("本周")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Statistics section - horizontal layout matching screenshot
            HStack(spacing: 0) {
                // Days studied
                StatItemView(
                    value: "\(daysStudied)",
                    label: "天数",
                    icon: "calendar",
                    color: .blue,
                    trend: "+2"
                )
                
                Spacer()
                
                // Minutes spent
                StatItemView(
                    value: "\(timeSpent)",
                    label: "分钟",
                    icon: "clock",
                    color: .orange,
                    trend: "+30"
                )
                
                Spacer()
                
                // Words learned
                StatItemView(
                    value: "\(wordsLearned)",
                    label: "单词",
                    icon: "book",
                    color: .green,
                    trend: "+15"
                )
            }
            .padding(.vertical, 5)
            
            // Weekly Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("本周目标完成度")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(weeklyGoalProgress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue.opacity(0.2))
                            .frame(height: 10)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * weeklyGoalProgress, height: 10)
                    }
                }
                .frame(height: 10)
            }
            
            // Last Updated and View Details Button
            HStack {
                Text("最后更新: 今天 14:30")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    // Action to view detailed statistics
                }) {
                    Text("查看详细统计")
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

// Renamed to avoid conflicts with any existing StatItem
struct StatItemView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Value with increase indicator
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                
                Text(trend)
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            // Label
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
    }
}

#Preview {
    LearningStatsCard()
        .padding()
        .background(Color.gray.opacity(0.1))
} 