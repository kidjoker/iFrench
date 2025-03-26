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
        VStack(spacing: 15) {
            // Header
            HStack {
                Text("学习统计")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("本周")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Statistics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                StatItem(
                    value: "\(daysStudied)",
                    label: "天数",
                    icon: "calendar",
                    color: .blue,
                    trend: "+2"
                )
                StatItem(
                    value: "\(timeSpent)",
                    label: "分钟",
                    icon: "clock.fill",
                    color: .orange,
                    trend: "+30"
                )
                StatItem(
                    value: "\(wordsLearned)",
                    label: "单词",
                    icon: "book.fill",
                    color: .green,
                    trend: "+15"
                )
            }
            
            // Weekly Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("本周目标完成度")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(Int(weeklyGoalProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: geometry.size.width, height: 6)
                            .foregroundColor(.blue.opacity(0.1))
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: geometry.size.width * weeklyGoalProgress, height: 6)
                            .foregroundColor(.blue)
                    }
                }
                .frame(height: 6)
            }
            
            // Last Updated and View Details Button
            HStack {
                Text("最后更新：今天 14:30")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                NavigationLink(destination: DetailedStatsView()) {
                    Text("查看详细统计")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct StatItem: View {
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
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }
            
            // Value and Trend
            HStack(alignment: .top, spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(trend)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(4)
            }
            
            // Label
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NavigationView {
        LearningStatsCard()
            .padding()
            .background(Color.gray.opacity(0.1))
    }
} 