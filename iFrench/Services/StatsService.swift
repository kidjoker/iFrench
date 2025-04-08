import Foundation
import Combine

/// 统计服务类，负责管理和处理学习统计数据
class StatsService: ObservableObject {
    static let shared = StatsService()
    
    @Published private(set) var learningStats: [LearningStats] = []
    @Published private(set) var summary: LearningStatsSummary?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let userDefaults = UserDefaults.standard
    private let statsKey = "learning_stats"
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        #if DEBUG
        // 在开发环境中使用 mock 数据
        self.learningStats = MockData.learningStats
        self.summary = MockData.learningStatsSummary
        #else
        loadStats()
        #endif
    }
    
    /// 加载统计数据
    private func loadStats() {
        guard let data = userDefaults.data(forKey: statsKey) else { return }
        
        do {
            learningStats = try JSONDecoder().decode([LearningStats].self, from: data)
            updateSummary()
        } catch {
            self.error = error
            print("Error loading stats: \(error)")
        }
    }
    
    /// 保存统计数据
    private func saveStats() {
        do {
            let data = try JSONEncoder().encode(learningStats)
            userDefaults.set(data, forKey: statsKey)
            updateSummary()
        } catch {
            self.error = error
            print("Error saving stats: \(error)")
        }
    }
    
    /// 添加新的学习记录
    func addLearningStats(_ stats: LearningStats) {
        learningStats.append(stats)
        saveStats()
    }
    
    /// 获取指定时间范围内的统计数据
    func getStats(for timeRange: TimeRange) -> [LearningStats] {
        #if DEBUG
        return MockData.getLearningStats(for: timeRange)
        #else
        let interval = timeRange.dateInterval
        return learningStats.filter { interval.contains($0.date) }
        #endif
    }
    
    /// 更新统计摘要
    private func updateSummary() {
        let weekStats = getStats(for: .week)
        
        // 计算总学习时长
        let totalDuration = learningStats.reduce(0) { $0 + $1.duration }
        
        // 计算主题分布
        let topicStats = Dictionary(grouping: weekStats) { $0.topic }
        let totalTime = weekStats.reduce(0) { $0 + $1.duration }
        let distribution = LearningTopic.allCases.map { topic in
            let topicTime = topicStats[topic]?.reduce(0) { $0 + $1.duration } ?? 0
            let percentage = totalTime > 0 ? (topicTime / totalTime) * 100 : 0
            return LearningStatsSummary.TopicDistribution(topic: topic, percentage: percentage)
        }
        
        // 计算连续学习天数
        let streakDays = calculateStreakDays()
        
        // 计算平均每日学习时长
        let averageDailyDuration = calculateAverageDailyDuration(for: .week)
        
        // 创建摘要
        summary = LearningStatsSummary(
            totalDuration: totalDuration,
            masteredWords: calculateMasteredWords(),
            completionRate: calculateCompletionRate(),
            retentionRate: calculateRetentionRate(),
            streakDays: streakDays,
            averageDailyDuration: averageDailyDuration,
            testPassRate: calculateTestPassRate(),
            completedCourses: learningStats.reduce(0) { $0 + $1.completedItems }, // 使用实际完成的项目数
            inProgressCourses: 4,
            topicDistribution: distribution
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateStreakDays() -> Int {
        let calendar = Calendar.current
        var streakDays = 0
        var currentDate = Date()
        
        while true {
            let dayStats = learningStats.filter {
                calendar.isDate($0.date, inSameDayAs: currentDate)
            }
            
            if dayStats.isEmpty {
                break
            }
            
            streakDays += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streakDays
    }
    
    private func calculateAverageDailyDuration(for timeRange: TimeRange) -> TimeInterval {
        let stats = getStats(for: timeRange)
        let calendar = Calendar.current
        let days = Set(stats.map { calendar.startOfDay(for: $0.date) }).count
        let totalDuration = stats.reduce(0) { $0 + $1.duration }
        return days > 0 ? totalDuration / Double(days) : 0
    }
    
    private func calculateMasteredWords() -> Int {
        // 示例实现，实际应根据词汇掌握度评估
        return Int.random(in: 1000...1500)
    }
    
    private func calculateCompletionRate() -> Double {
        let completedItems = learningStats.reduce(0) { $0 + $1.completedItems }
        let totalItems = completedItems + 20 // 示例：假设还有20个待完成项
        return Double(completedItems) / Double(totalItems) * 100
    }
    
    private func calculateRetentionRate() -> Double {
        // 示例实现，实际应根据复习测试结果计算
        return Double.random(in: 85...95)
    }
    
    private func calculateTestPassRate() -> Double {
        let passedTests = learningStats.filter { $0.accuracy >= 0.6 }.count
        return learningStats.isEmpty ? 0 : Double(passedTests) / Double(learningStats.count) * 100
    }
}

// MARK: - Error Types
extension StatsService {
    enum StatsError: Error {
        case loadError
        case saveError
        case invalidData
    }
} 