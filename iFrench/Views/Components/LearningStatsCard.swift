//
//  LearningStatsCard.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI
import iFrench // Assuming LearningSummary is defined in the main target

struct LearningStatsCard: View {
    @StateObject private var statsService = StatsService.shared
    @State private var selectedTimeframe: TimeRange = .week
    
    var body: some View {
        NavigationLink(destination: DetailedStatsView()) {
            VStack(alignment: .leading, spacing: 15) {
                headerView
                
                if let summary = statsService.summary {
                    statsGridView(summary: summary)
                    weeklyProgressView(summary: summary)
                    footerView
                } else {
                    // Placeholder for loading or error state
                    Text("正在加载统计数据...")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        // Consider fetching stats when the timeframe changes or on appear
        // .onChange(of: selectedTimeframe) { _ in statsService.fetchSummary(for: selectedTimeframe) }
        // .onAppear { statsService.fetchSummary(for: selectedTimeframe) } // Assuming fetchSummary exists
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text("学习统计")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            // Timeframe Picker
            Picker("时间范围", selection: $selectedTimeframe) {
                ForEach(TimeRange.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.menu)
            // Add accessibility label
            .accessibilityLabel("选择学习统计的时间范围")
        }
    }
    
    private func statsGridView(summary: LearningStatsSummary) -> some View {
        HStack(spacing: 0) {
            // Days studied
            StatItemView(
                value: "\(summary.streakDays)",
                label: "连续天数",
                icon: "calendar",
                color: .blue,
                // TODO: Replace with actual trend calculation from StatsService
                trend: calculateTrend(current: summary.streakDays, previous: 3) // Example previous value
            )
            
            Spacer()
            
            // Minutes spent
            StatItemView(
                value: "\(Int(summary.averageDailyDuration / 60))",
                label: "平均时长",
                icon: "clock",
                color: .orange,
                // TODO: Replace with actual trend calculation from StatsService
                trend: calculateTrend(current: Int(summary.averageDailyDuration / 60), previous: 25) // Example previous value (in minutes)
            )
            
            Spacer()
            
            // Words learned
            StatItemView(
                value: "\(summary.masteredWords)",
                label: "已掌握",
                icon: "book",
                color: .green,
                // TODO: Replace with actual trend calculation from StatsService
                trend: calculateTrend(current: summary.masteredWords, previous: 980) // Example previous value
            )
        }
        .padding(.vertical, 5)
        // Add accessibility container behavior if needed
        .accessibilityElement(children: .combine)
        .accessibilityLabel("学习统计摘要：连续\(summary.streakDays)天，平均时长\(Int(summary.averageDailyDuration / 60))分钟，已掌握\(summary.masteredWords)个单词。")
    }
    
    private func weeklyProgressView(summary: LearningStatsSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("本周目标完成度") // Consider making this dynamic based on timeframe
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(summary.completionRate))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: summary.completionRate / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 10)
                .accessibilityLabel("周目标完成度")
                .accessibilityValue("\(Int(summary.completionRate))%")
                
                /* // Original GeometryReader implementation (alternative)
                 GeometryReader { geometry in
                 ZStack(alignment: .leading) {
                 // Background
                 RoundedRectangle(cornerRadius: 5)
                 .fill(Color.blue.opacity(0.2))
                 .frame(height: 10)
                 
                 // Progress
                 RoundedRectangle(cornerRadius: 5)
                 .fill(Color.blue)
                 .frame(width: max(0, geometry.size.width * summary.completionRate / 100), height: 10) // Ensure width is not negative
                 }
                 }
                 .frame(height: 10)
                 */
        }
    }
    
    private var footerView: some View {
        HStack {
            // Get the date from the last detailed stat entry for the timeframe
            let lastUpdateDate = statsService.getStats(for: selectedTimeframe).last?.date
            
            if let date = lastUpdateDate {
                Text("数据截至: \(formatDate(date))") // Changed text slightly
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("暂无更新信息")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("查看详细统计")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.top, 5)
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        // Consider using relative date formatting for recent updates
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Placeholder for trend calculation logic (should be moved to StatsService)
    private func calculateTrend(current: Int, previous: Int) -> String {
        let difference = current - previous
        if difference > 0 {
            return "+\(difference)"
        } else if difference < 0 {
            return "\(difference)" // Shows negative sign automatically
        } else {
            return "±0" // Or "" for no change
        }
    }
    
    private var backgroundColor: Color {
        #if os(iOS) || os(visionOS)
        Color(UIColor.systemBackground)
        #else
        Color(.windowBackgroundColor) // macOS
        #endif
    }
}

// MARK: - StatItemView

struct StatItemView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let trend: String // Trend is now just a string (e.g., "+5", "-2", "±0")
    
    // Determine trend color based on value
    private var trendColor: Color {
        if trend.starts(with: "+") {
            return .green
        } else if trend.starts(with: "-") {
            return .red
        } else {
            return .orange // Or .secondary
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 55, height: 55) // Slightly smaller?
                
                Image(systemName: icon)
                    .font(.title3) // Slightly smaller?
                    .foregroundColor(color)
            }
            
            // Value with trend indicator
            HStack(alignment: .firstTextBaseline, spacing: 4) { // Use firstTextBaseline for better alignment
                Text(value)
                    .font(.system(size: 24, weight: .bold)) // Slightly smaller?
                    .lineLimit(1) // Ensure value doesn't wrap awkwardly
                
                // Only show trend if it's not zero or empty
                if !trend.isEmpty && trend != "±0" {
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(trendColor)
                }
            }
            
            // Label
            Text(label)
                .font(.caption) // Use caption for consistency
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(minWidth: 80, idealWidth: 90, maxWidth: 100) // Flexible width
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
        .accessibilityValue(trend.isEmpty || trend == "±0" ? "无变化" : "变化 \(trend)")
    }
}

// MARK: - Preview

#Preview {
    // Mock StatsService for preview if needed
    // let mockService = StatsService()
    // mockService.summary = LearningSummary(...) // Populate with mock data
    
    LearningStatsCard()
    // .environmentObject(mockService) // Inject mock service
        .padding()
        .background(Color.gray.opacity(0.1))
}

// MARK: - Supporting Types (Assuming these exist elsewhere)

// Placeholder definitions removed as they likely exist elsewhere in the project.