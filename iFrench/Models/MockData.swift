import Foundation
import SwiftUI

/// Mock data provider for development and testing
enum MockData {
    // MARK: - Learning Stats
    static let learningStats: [LearningStats] = [
        // Last 7 days
        LearningStats(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
            duration: 1800, // 30 minutes
            topic: .vocabulary,
            completedItems: 20,
            accuracy: 0.85
        ),
        LearningStats(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            duration: 2400, // 40 minutes
            topic: .grammar,
            completedItems: 15,
            accuracy: 0.90
        ),
        LearningStats(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            duration: 1200, // 20 minutes
            topic: .listening,
            completedItems: 10,
            accuracy: 0.75
        ),
        LearningStats(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            duration: 3000, // 50 minutes
            topic: .pronunciation,
            completedItems: 25,
            accuracy: 0.88
        ),
        LearningStats(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            duration: 2700, // 45 minutes
            topic: .speaking,
            completedItems: 18,
            accuracy: 0.82
        ),
        LearningStats(
            id: UUID(),
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            duration: 1500, // 25 minutes
            topic: .vocabulary,
            completedItems: 22,
            accuracy: 0.95
        ),
        LearningStats(
            id: UUID(),
            date: Date(),
            duration: 2100, // 35 minutes
            topic: .grammar,
            completedItems: 17,
            accuracy: 0.87
        )
    ]
    
    // MARK: - Vocabulary Words
    static let vocabularyWords: [VocabularyWord] = [
        VocabularyWord(
            french: "bonjour",
            chinese: "你好",
            phonetic: "bɔ̃ʒuʁ",
            difficulty: 1,
            nextReviewDate: Date().addingTimeInterval(24 * 60 * 60)
        ),
        VocabularyWord(
            french: "merci",
            chinese: "谢谢",
            phonetic: "mɛʁsi",
            difficulty: 1,
            nextReviewDate: Date().addingTimeInterval(24 * 60 * 60)
        ),
        VocabularyWord(
            french: "au revoir",
            chinese: "再见",
            phonetic: "o ʁəvwaʁ",
            difficulty: 1,
            nextReviewDate: Date().addingTimeInterval(24 * 60 * 60)
        )
    ]
    
    // MARK: - Listening Exercises
    static let listeningExercises: [ListeningExercise] = [
        ListeningExercise(
            title: "基础对话 1",
            audioFileName: "Hello Goodbye in French Lesson 1.mp3",
            audioLength: 30,
            transcript: "Bonjour! Comment allez-vous?",
            question: "这段对话在问什么？",
            options: ["问候", "告别", "道歉", "感谢"],
            correctOptionIndex: 0,
            difficulty: .beginner,
            type: .precision
        ),
        ListeningExercise(
            title: "餐厅场景",
            audioFileName: "cafe_order.mp3",
            audioLength: 45,
            transcript: "Je voudrais un café, s'il vous plaît.",
            question: "说话人想要什么？",
            options: ["咖啡", "茶", "水", "果汁"],
            correctOptionIndex: 0,
            difficulty: .intermediate,
            type: .extensive
        )
    ]
    
    // MARK: - User Profile
    static var user: User {
        User(username: "学习者", email: "learner@example.com")
    }
    
    // MARK: - App Settings
    static let appSettings = AppSettings()
    
    // MARK: - Mascot
    static let selectedMascot = Mascot.frog
    
    // MARK: - Learning Stats Summary
    static var learningStatsSummary: LearningStatsSummary {
        LearningStatsSummary(
            totalDuration: 14700, // 245 minutes in seconds
            masteredWords: 102,
            completionRate: 85,
            retentionRate: 92,
            streakDays: 7,
            averageDailyDuration: 2100, // 35 minutes in seconds
            testPassRate: 88,
            completedCourses: 2,
            inProgressCourses: 1,
            topicDistribution: [
                LearningStatsSummary.TopicDistribution(topic: .vocabulary, percentage: 30),
                LearningStatsSummary.TopicDistribution(topic: .grammar, percentage: 25),
                LearningStatsSummary.TopicDistribution(topic: .pronunciation, percentage: 15),
                LearningStatsSummary.TopicDistribution(topic: .listening, percentage: 20),
                LearningStatsSummary.TopicDistribution(topic: .speaking, percentage: 10)
            ]
        )
    }
}

// MARK: - Helper Extensions
extension MockData {
    /// 获取指定时间范围内的学习统计数据
    static func getLearningStats(for timeRange: TimeRange) -> [LearningStats] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .quarter:
            startDate = calendar.date(byAdding: .month, value: -3, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }
        
        return learningStats.filter { $0.date >= startDate && $0.date <= now }
    }
    
    /// 获取指定难度等级的词汇
    static func getVocabularyWords(for difficulty: Int) -> [VocabularyWord] {
        vocabularyWords.filter { $0.difficulty == difficulty }
    }
    
    /// 获取指定难度等级的听力练习
    static func getListeningExercises(for difficulty: ListeningExercise.Difficulty) -> [ListeningExercise] {
        listeningExercises.filter { $0.difficulty == difficulty }
    }
} 