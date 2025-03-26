import SwiftUI
import Charts

struct DetailedStatsView: View {
    @State private var selectedTimeframe = "本周"
    @State private var selectedTab = "daily"
    
    // Sample data
    let timeframes = ["本周", "本月", "本季度", "今年"]
    let learningData: [(date: String, minutes: Double)] = [
        ("周一", 120),
        ("周二", 90),
        ("周三", 150),
        ("周四", 80),
        ("周五", 130),
        ("周六", 60),
        ("周日", 40)
    ]
    
    let topicDistribution: [(topic: String, percentage: Double)] = [
        ("发音", 35),
        ("词汇", 25),
        ("语法", 20),
        ("听力", 15),
        ("口语", 5)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Summary Cards
                summaryCardsSection
                
                // Charts
                learningTrendsSection
                
                // Tabs Content
                tabsSection
            }
            .padding()
        }
        .navigationTitle("详细统计")
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("学习分析")
                    .font(.headline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                Spacer()
                Picker("时间范围", selection: $selectedTimeframe) {
                    ForEach(timeframes, id: \.self) { timeframe in
                        Text(timeframe).tag(timeframe)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Text("跟踪你的学习进度和成就")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatsSummaryCard(
                title: "总学习时长",
                value: "120.5",
                unit: "小时",
                trend: "+15.2%",
                isPositive: true
            )
            StatsSummaryCard(
                title: "已掌握单词",
                value: "1,248",
                unit: "个",
                trend: "+8%",
                isPositive: true
            )
            StatsSummaryCard(
                title: "完成率",
                value: "85",
                unit: "%",
                trend: "-2%",
                isPositive: false
            )
            StatsSummaryCard(
                title: "记忆保持",
                value: "92",
                unit: "%",
                trend: "+4%",
                isPositive: true
            )
        }
    }
    
    private var learningTrendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习趋势")
                .font(.headline)
            
            Chart {
                ForEach(learningData, id: \.date) { item in
                    BarMark(
                        x: .value("日期", item.date),
                        y: .value("时长", item.minutes)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
    
    private var tabsSection: some View {
        VStack(spacing: 15) {
            // Custom Tab Bar
            HStack {
                TabButton(title: "每日明细", isSelected: selectedTab == "daily") {
                    selectedTab = "daily"
                }
                TabButton(title: "主题分布", isSelected: selectedTab == "topics") {
                    selectedTab = "topics"
                }
                TabButton(title: "详细指标", isSelected: selectedTab == "metrics") {
                    selectedTab = "metrics"
                }
            }
            .padding(.horizontal)
            
            // Tab Content
            switch selectedTab {
            case "daily":
                dailyBreakdownView
            case "topics":
                topicsDistributionView
            case "metrics":
                metricsView
            default:
                EmptyView()
            }
        }
    }
    
    private var dailyBreakdownView: some View {
        VStack(spacing: 15) {
            ForEach(learningData, id: \.date) { item in
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(item.date)
                    Spacer()
                    Text("\(Int(item.minutes))分钟")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
            }
        }
    }
    
    private var topicsDistributionView: some View {
        VStack(spacing: 15) {
            ForEach(topicDistribution, id: \.topic) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.topic)
                        Spacer()
                        Text("\(Int(item.percentage))%")
                            .foregroundColor(.blue)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 8)
                                .opacity(0.1)
                                .foregroundColor(.blue)
                            
                            Rectangle()
                                .frame(width: geometry.size.width * item.percentage / 100, height: 8)
                                .foregroundColor(.blue)
                        }
                        .cornerRadius(4)
                    }
                    .frame(height: 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
            }
        }
    }
    
    private var metricsView: some View {
        VStack(spacing: 15) {
            MetricCard(
                title: "平均每日学习",
                value: "2.1",
                unit: "小时",
                icon: "clock.fill",
                description: "较上月提升0.3小时"
            )
            MetricCard(
                title: "最长连续学习",
                value: "32",
                unit: "天",
                icon: "flame.fill",
                description: "当前连续：12天"
            )
            MetricCard(
                title: "测验通过率",
                value: "92",
                unit: "%",
                icon: "checkmark.circle.fill",
                description: "共完成48次测验"
            )
            MetricCard(
                title: "完成课程",
                value: "8",
                unit: "个",
                icon: "star.fill",
                description: "4个课程进行中"
            )
        }
    }
}

struct StatsSummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(isPositive ? .green : .red)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(trend)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isPositive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .foregroundColor(isPositive ? .green : .red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(isSelected ? .white : .gray)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        DetailedStatsView()
    }
} 