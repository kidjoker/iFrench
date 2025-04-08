import Foundation
import Combine

/// Service responsible for authentication operations
public class AuthService: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance for global access
    public static let shared = AuthService()
    
    // MARK: - Published Properties
    
    /// Current user, if logged in
    @Published public var currentUser: User?
    
    /// Authentication state
    @Published public var authState: AuthState = .notAuthenticated
    
    /// True if authentication is in progress
    @Published public var isLoading = false
    
    /// Most recent error message, if any
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    
    /// User defaults key for storing user data
    private let userDefaultsKey = "currentUser"
    
    // MARK: - Initialization
    
    private init() {
        // Attempt to load saved user on initialization
        loadSavedUser()
    }
    
    // MARK: - Public Methods
    
    /// Logs in a user with the given credentials
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - completion: Closure called after login attempt completes
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        authState = .authenticating
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // In a real app, this would verify credentials with a backend service
            // For demo purposes, accept any non-empty values except specific test cases
            
            if email.isEmpty || password.isEmpty {
                self.handleAuthFailure(message: "邮箱或密码不能为空")
                completion(false)
                return
            }
            
            // Test case for error
            if email.lowercased() == "error@example.com" {
                self.handleAuthFailure(message: "邮箱或密码不正确")
                completion(false)
                return
            }
            
            // Create demo user
            let user = User(
                username: email.components(separatedBy: "@").first ?? "用户",
                email: email,
                lastLoginDate: Date(),
                streak: Int.random(in: 1...10),
                totalDuration: TimeInterval(Int.random(in: 3600...10800)), // 1-3 hours in seconds
                masteredWords: Int.random(in: 30...60)
            )
            
            self.currentUser = user
            self.saveUserToDefaults(user)
            self.authState = .authenticated
            self.isLoading = false
            completion(true)
        }
    }
    
    /// Registers a new user
    /// - Parameters:
    ///   - username: User's chosen username
    ///   - email: User's email
    ///   - password: User's password
    ///   - completion: Closure called after registration attempt completes
    func register(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        authState = .authenticating
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // In a real app, this would send registration details to a backend service
            // For demo purposes, validate input and create a local user
            
            // Validate input
            if username.isEmpty || email.isEmpty || password.isEmpty {
                self.handleAuthFailure(message: "所有字段必须填写")
                completion(false)
                return
            }
            
            if password.count < 8 {
                self.handleAuthFailure(message: "密码长度必须至少为8个字符")
                completion(false)
                return
            }
            
            // Test case for email already in use
            if email.lowercased() == "taken@example.com" {
                self.handleAuthFailure(message: "该邮箱已被注册")
                completion(false)
                return
            }
            
            // Create new user
            let user = User(
                username: username,
                email: email,
                joinDate: Date(),
                lastLoginDate: Date()
            )
            
            self.currentUser = user
            self.saveUserToDefaults(user)
            self.authState = .authenticated
            self.isLoading = false
            completion(true)
        }
    }
    
    /// Logs out the current user
    func logout() {
        self.currentUser = nil
        self.authState = .notAuthenticated
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    // MARK: - Private Methods
    
    /// Handles authentication failure
    /// - Parameter message: Error message
    private func handleAuthFailure(message: String) {
        errorMessage = message
        authState = .failed
        isLoading = false
    }
    
    /// Saves user to UserDefaults
    /// - Parameter user: User to save
    private func saveUserToDefaults(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    /// Loads saved user from UserDefaults
    private func loadSavedUser() {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.authState = .authenticated
        }
    }
    
    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        return authState == .authenticated && currentUser != nil
    }
}

/// Represents the application's authentication state
public enum AuthState {
    case notAuthenticated
    case authenticating
    case authenticated
    case failed
} 