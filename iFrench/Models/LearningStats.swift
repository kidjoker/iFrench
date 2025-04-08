import Foundation

/// 学习统计数据模型
struct LearningStats: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let topic: LearningTopic
    let completedItems: Int
    let accuracy: Double
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        topic: LearningTopic,
        completedItems: Int,
        accuracy: Double
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.topic = topic
        self.completedItems = completedItems
        self.accuracy = accuracy
    }
}

/// 学习主题枚举
enum LearningTopic: String, Codable, CaseIterable {
    case pronunciation = "发音"
    case vocabulary = "词汇"
    case grammar = "语法"
    case listening = "听力"
    case speaking = "口语"
}

/// 学习统计摘要
struct LearningStatsSummary: Codable {
    let totalDuration: TimeInterval
    let masteredWords: Int
    let completionRate: Double
    let retentionRate: Double
    let streakDays: Int
    let averageDailyDuration: TimeInterval
    let testPassRate: Double
    let completedCourses: Int
    let inProgressCourses: Int
    
    var topicDistribution: [TopicDistribution]
    
    struct TopicDistribution: Codable, Identifiable {
        let id: UUID
        let topic: LearningTopic
        let percentage: Double
        
        init(id: UUID = UUID(), topic: LearningTopic, percentage: Double) {
            self.id = id
            self.topic = topic
            self.percentage = percentage
        }
    }
}

/// 时间范围枚举
enum TimeRange: String, CaseIterable {
    case week = "本周"
    case month = "本月"
    case quarter = "本季度"
    case year = "今年"
    
    var dateInterval: DateInterval {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return DateInterval(start: weekStart, end: now)
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return DateInterval(start: monthStart, end: now)
        case .quarter:
            let quarter = (calendar.component(.month, from: now) - 1) / 3
            let quarterStart = calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarter * 3 + 1))!
            return DateInterval(start: quarterStart, end: now)
        case .year:
            let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return DateInterval(start: yearStart, end: now)
        }
    }
} 