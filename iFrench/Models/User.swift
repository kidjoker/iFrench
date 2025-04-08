import Foundation

public struct User: Identifiable, Codable {
    public let id: String
    public let username: String
    public let email: String
    public let profileImageURL: String?
    public let joinDate: Date
    public let lastLoginDate: Date
    public let streak: Int
    public let totalDuration: TimeInterval
    public let masteredWords: Int
    
    public init(
        id: String = UUID().uuidString,
        username: String,
        email: String,
        profileImageURL: String? = nil,
        joinDate: Date = Date(),
        lastLoginDate: Date = Date(),
        streak: Int = 0,
        totalDuration: TimeInterval = 0,
        masteredWords: Int = 0
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageURL = profileImageURL
        self.joinDate = joinDate
        self.lastLoginDate = lastLoginDate
        self.streak = streak
        self.totalDuration = totalDuration
        self.masteredWords = masteredWords
    }
    
    // Create a demo user for preview purposes
    public static var demoUser: User {
        User(
            id: "demo-user-1",
            username: "学习者",
            email: "learner@example.com",
            profileImageURL: nil,
            joinDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            lastLoginDate: Date(),
            streak: 7,
            totalDuration: 7200, // 2 hours in seconds
            masteredWords: 45
        )
    }
} 