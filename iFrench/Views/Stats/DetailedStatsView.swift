import SwiftUI
import Charts

/// A view displaying detailed learning statistics with charts and breakdowns.
struct DetailedStatsView: View {
    // MARK: - State and Environment
    @StateObject private var statsService = StatsService.shared
    @State private var selectedTimeframe: TimeRange = .week
    @State private var selectedTab = "daily" // Default tab

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) { // Increased spacing
                // Header Section with Title and Timeframe Picker
                headerSection

                // Summary Cards Grid
                summaryCardsSection

                // Learning Trends Chart Section
                learningTrendsSection

                // Tabbed Section for Detailed Breakdowns
                tabsSection
            }
            .padding() // Padding around the main VStack content
        }
        .navigationTitle("详细统计") // Detailed Stats
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea(.container, edges: .bottom)) // Adaptive background
        // Fetch data when timeframe changes (consider adding initial fetch on appear if needed)
        // .onChange(of: selectedTimeframe) { _, newTimeframe in
        //     statsService.fetchSummary(for: newTimeframe) // Assuming fetchSummary exists and updates necessary data
        //     statsService.fetchDetailedStats(for: newTimeframe) // Assuming fetchDetailedStats exists
        // }
    }

    // MARK: - Subviews

    /// Header with title and timeframe picker.
    private var headerSection: some View {
        HStack {
            Text("学习分析") // Learning Analysis
                .font(.headline)
                // Removed capsule background for cleaner look
            Spacer()
            Picker("时间范围", selection: $selectedTimeframe) { // Time Range
                ForEach(TimeRange.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue).tag(timeframe)
                }
            }
            .pickerStyle(.menu)
        }
        // Removed description text - title is self-explanatory
    }

    /// Grid displaying summary statistic cards.
    private var summaryCardsSection: some View {
        // Use two flexible columns for the grid
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)], spacing: 15) {
            // Check if summary data is available
            if let summary = statsService.summary {
                StatsSummaryCard(
                    title: "总学习时长", // Total Duration
                    value: formatDuration(summary.totalDuration), // Use helper
                    unit: "小时", // hours
                    trend: "+15.2%", // Example trend data
                    isPositive: true
                )
                StatsSummaryCard(
                    title: "已掌握单词", // Mastered Words
                    value: "\(summary.masteredWords)",
                    unit: "个", // words
                    trend: "+8%", // Example
                    isPositive: true
                )
                StatsSummaryCard(
                    title: "完成率", // Completion Rate
                    value: String(format: "%.1f", summary.completionRate),
                    unit: "%",
                    trend: "-2%", // Example
                    isPositive: false // Assuming lower completion rate trend is negative
                )
                StatsSummaryCard(
                    title: "记忆保持", // Retention Rate
                    value: String(format: "%.1f", summary.retentionRate),
                    unit: "%",
                    trend: "+4%", // Example
                    isPositive: true
                )
            } else {
                 // Optionally show placeholder cards or a loading indicator
                 ForEach(0..<4) { _ in // Placeholder count matches card count
                     RoundedRectangle(cornerRadius: 15)
                         .fill(Color(.secondarySystemGroupedBackground))
                         .frame(height: 100) // Match approx card height
                         .redacted(reason: .placeholder)
                 }
            }
        }
    }

    /// Section displaying the learning trends chart.
    private var learningTrendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习趋势 (分钟/天)") // Learning Trends (Minutes/Day)
                .font(.headline)

            let statsData = statsService.getStats(for: selectedTimeframe)

            if !statsData.isEmpty {
                Chart {
                    ForEach(statsData) { stat in
                        BarMark(
                            x: .value("日期", stat.date, unit: .day), // Use date directly
                            y: .value("时长", stat.duration / 60) // Convert to minutes
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .cornerRadius(4) // Add corner radius to bars
                    }
                }
                // Customize chart axes for clarity
                .chartXAxis {
                    // Show axis labels for dates, format as needed
                     AxisMarks(values: .stride(by: .day)) { value in
                         AxisGridLine()
                         AxisTick()
                         AxisValueLabel(format: .dateTime.month().day()) // MM-dd format
                     }
                }
                .chartYAxis {
                    // Optional: Customize Y-axis labels/grid
                    AxisMarks(position: .leading)
                }
                .frame(height: 200) // Set fixed height
            } else {
                // Placeholder if no chart data
                 Text("暂无趋势数据")
                     .foregroundColor(.secondary)
                     .frame(height: 200, alignment: .center)
                     .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.regularMaterial) // Use adaptive material
        .cornerRadius(15)
    }

    /// Section containing the tab bar and corresponding tab content.
    private var tabsSection: some View {
        VStack(spacing: 15) {
            // Custom Tab Bar using TabButton component
            HStack {
                TabButton(title: "每日明细", isSelected: selectedTab == "daily") { selectedTab = "daily" }
                TabButton(title: "主题分布", isSelected: selectedTab == "topics") { selectedTab = "topics" }
                TabButton(title: "详细指标", isSelected: selectedTab == "metrics") { selectedTab = "metrics" }
            }
            .padding(5) // Inner padding for the bar background
            .background(Color(.secondarySystemGroupedBackground)) // Adaptive background for the bar
            .cornerRadius(10) // Rounded corners for the bar

            // Tab Content Area
            // Use a container to manage transitions if desired
            Group {
                switch selectedTab {
                case "daily":
                    dailyBreakdownView
                case "topics":
                    topicsDistributionView
                case "metrics":
                    metricsView
                default:
                    EmptyView() // Should not happen, but good practice
                }
            }
             // Optional: Add transitions between tabs
             // .transition(.opacity)
             // .id(selectedTab) // Change ID to trigger transition
        }
    }

    /// View displaying the daily breakdown list.
    private var dailyBreakdownView: some View {
        VStack(spacing: 10) { // Reduced spacing
             let statsData = statsService.getStats(for: selectedTimeframe)
             if !statsData.isEmpty {
                 ForEach(statsData) { stat in
                     HStack {
                         Image(systemName: "calendar")
                             .foregroundColor(.secondary) // Semantic color
                         Text(formatDateForList(stat.date)) // Use a different format?
                         Spacer()
                         Text("\(Int(stat.duration / 60)) 分钟") // minutes
                             .foregroundColor(.blue) // Keep blue or use .primary
                             .fontWeight(.medium)
                     }
                     .padding()
                     .background(.regularMaterial) // Use material
                     .cornerRadius(10)
                 }
             } else {
                 Text("无每日数据") // No daily data
                     .foregroundColor(.secondary)
                     .padding()
             }
        }
    }

    /// View displaying the topic distribution using ProgressView.
    private var topicsDistributionView: some View {
        VStack(spacing: 15) {
            // Use summary data if available
            if let summary = statsService.summary, !summary.topicDistribution.isEmpty {
                ForEach(summary.topicDistribution) { item in // Assuming TopicDistribution is Identifiable
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item.topic.rawValue) // Assuming topic is an enum with rawValue
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(String(format: "%.1f%%", item.percentage))
                                .font(.subheadline)
                                .foregroundColor(.secondary) // Use secondary for percentage
                        }

                        ProgressView(value: item.percentage / 100.0) // Use ProgressView
                            .tint(.blue) // Set tint color
                            .scaleEffect(x: 1, y: 1.5, anchor: .center) // Make bar slightly thicker
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
                }
            } else {
                Text("无主题分布数据") // No topic distribution data
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }

    /// View displaying detailed metrics using MetricCard.
    private var metricsView: some View {
        VStack(spacing: 15) {
            // Use summary data if available
            if let summary = statsService.summary {
                MetricCard(
                    title: "平均每日学习", // Avg Daily Study
                    value: formatDuration(summary.averageDailyDuration),
                    unit: "小时", // hours
                    icon: "clock.fill",
                    description: "较上月提升0.3小时", // Example description
                    tintColor: .orange // Example tint
                )
                MetricCard(
                    title: "最长连续学习", // Longest Streak
                    value: "\(summary.streakDays)",
                    unit: "天", // days
                    icon: "flame.fill",
                    description: "当前连续: \(summary.streakDays)天", // Current streak
                    tintColor: .red
                )
                MetricCard(
                    title: "测验通过率", // Test Pass Rate
                    value: String(format: "%.1f", summary.testPassRate),
                    unit: "%",
                    icon: "checkmark.circle.fill",
                    description: "共完成48次测验", // Example
                    tintColor: .green
                )
                MetricCard(
                    title: "完成课程", // Completed Courses
                    value: "\(summary.completedCourses)",
                    unit: "个", // courses
                    icon: "star.fill",
                    description: "\(summary.inProgressCourses)个课程进行中", // In progress
                    tintColor: .purple
                )
            } else {
                Text("无详细指标数据") // No detailed metrics data
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }

    // MARK: - Helper Methods

    /// Formats a date specifically for the Chart's X-axis.
    private func formatDateForChart(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd" // Example: 03-25
        return formatter.string(from: date)
    }

    /// Formats a date specifically for the daily list view.
    private func formatDateForList(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Example: Mar 25, 2025
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Formats a time duration (in seconds) into a string like "X.Y".
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = max(0, duration) / 3600 // Ensure non-negative
        return String(format: "%.1f", hours)
    }
}

// MARK: - Preview
#Preview {
    // Wrap in NavigationStack for preview context
    NavigationStack {
        DetailedStatsView()
            // Provide mock services/data for preview if needed
            // .environmentObject(StatsService.shared) // Use a shared mock if available
    }
} 