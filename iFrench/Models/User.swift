import Foundation

public struct User: Identifiable, Codable {
    public var id: String
    public var username: String
    public var email: String
    public var profileImageURL: String?
    public var joinDate: Date
    public var lastLoginDate: Date
    public var streak: Int
    public var totalStudyTimeMinutes: Int
    public var wordsLearned: Int
    
    public init(id: String = UUID().uuidString,
         username: String,
         email: String,
         profileImageURL: String? = nil,
         joinDate: Date = Date(),
         lastLoginDate: Date = Date(),
         streak: Int = 0,
         totalStudyTimeMinutes: Int = 0,
         wordsLearned: Int = 0) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageURL = profileImageURL
        self.joinDate = joinDate
        self.lastLoginDate = lastLoginDate
        self.streak = streak
        self.totalStudyTimeMinutes = totalStudyTimeMinutes
        self.wordsLearned = wordsLearned
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
            totalStudyTimeMinutes: 120,
            wordsLearned: 45
        )
    }
} 