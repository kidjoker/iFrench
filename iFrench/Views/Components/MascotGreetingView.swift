//
//  MascotGreetingView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

/// A view displaying a greeting message from a selected mascot.
///
/// This view fetches a personalized message using `AIService` based on the
/// current user and the selected mascot. It handles loading and error states.
struct MascotGreetingView: View {
    // MARK: - Environment and State Objects
    
    @EnvironmentObject private var authService: AuthService
    @StateObject private var aiService = AIService.shared
    
    // MARK: - Bindings and State
    
    /// The currently selected mascot, passed from the parent view.
    @Binding var selectedMascot: Mascot
    
    /// The greeting message received from the AI service.
    @State private var message: String = ""
    /// Indicates if the AI service is currently fetching a message.
    @State private var isLoading: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 15) {
            mascotAvatar
            messageContent
            Spacer() // Pushes content to the left
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onAppear(perform: generateMessage)
        .onChange(of: selectedMascot) { _, _ in generateMessage() }
        // Consider adding onChange for authService.currentUser if relevant
    }
    
    // MARK: - Computed Subviews
    
    /// Displays the mascot's avatar image within a colored circle.
    private var mascotAvatar: some View {
        ZStack {
            Circle()
                .fill(selectedMascot.color.opacity(0.2))
                .frame(width: 70, height: 70)
            
            mascotImage
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(selectedMascot.color)
        }
        .accessibilityLabel("\(selectedMascot.rawValue) mascot")
    }
    
    /// Displays the loading indicator, error message, or the greeting message.
    @ViewBuilder
    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Display Loading or Message
            if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8) // Slightly smaller spinner
                    Text("正在生成...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if message.isEmpty {
                 Text("轻点一下生成问候！") // Or a default placeholder
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.primary) // Use primary color for the actual message
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .scale(scale: 0.95))) // Add subtle transition
            }
        }
        // Animate changes to the content within the VStack
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: message)
    }
    
    /// Gets the appropriate system image name for the selected mascot.
    /// Note: Ideally, this logic would live within the Mascot enum itself.
    private var mascotImage: Image {
        switch selectedMascot {
        case .frog:
            // Assuming these are placeholders and you have actual mascot images
            return Image(systemName: "tortoise.fill") // Placeholder
        case .owl:
            return Image(systemName: "owl") // Placeholder
        case .fox:
            return Image(systemName: "hare.fill") // Placeholder
        }
    }
    
    /// Gets the background color appropriate for the OS.
    private var backgroundColor: Color {
        #if os(iOS) || os(visionOS)
        Color(UIColor.systemBackground)
        #else
        Color(.windowBackgroundColor) // macOS
        #endif
    }
    
    // MARK: - Helper Methods
    
    /// Initiates the process to generate a personalized message using the AI service.
    /// Handles loading and error states.
    private func generateMessage() {
        // Start loading sequence
        isLoading = true
        message = ""      // Clear previous message while loading new one

        // Define the completion handler block with the correct signature
        let completionHandler: (String) -> Void = { generatedMessage in
            // Ensure UI updates are on the main thread
            DispatchQueue.main.async {
                self.isLoading = false // Stop loading
                self.message = generatedMessage // Update the message
            }
        }

        // Call the service with the defined handler
        aiService.generateDailyMessage(
            user: authService.currentUser,
            mascot: selectedMascot,
            completion: completionHandler // Pass the handler here
        )
    }
}

// MARK: - Preview

#Preview {
    // Mock Mascot type if not available globally
    /*
     enum Mascot: String, CaseIterable, Identifiable {
     case frog = "Frog"
     case owl = "Owl"
     case fox = "Fox"
     var id: String { self.rawValue }
     var color: Color {
     switch self {
     case .frog: .green
     case .owl: .purple
     case .fox: .orange
     }
     }
     }
     */
    
    // Mock AIService for preview if needed
    /*
     class MockAIService: AIService {
         override func generateDailyMessage(user: User?, mascot: Mascot, completion: @escaping (Result<String, Error>) -> Void) {
             isLoading = true
             DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                 isLoading = false
                 // Simulate success or failure
                 // completion(.success("来自\(mascot.rawValue)的你好！今天天气不错。"))
                 completion(.failure(NSError(domain: "PreviewError", code: 1, userInfo: [NSLocalizedDescriptionKey: "模拟错误"])))
             }
         }
     }
     */
    
    MascotGreetingView(selectedMascot: .constant(.owl)) // Change mascot for different previews
        .environmentObject(AuthService.shared) // Ensure a mock/shared AuthService is available
        // .environmentObject(MockAIService.shared) // Inject mock AI service for preview
        .padding()
        .background(Color.gray.opacity(0.1))
}

// MARK: - Assumed Supporting Types (Ensure these exist)

/*
 // --- Assumed definitions ---
 
 enum Mascot: String /* ... adopt necessary protocols ... */ {
 case frog, owl, fox
 // Add properties like color, imageName here if possible
 var color: Color { /* ... */ }
 // var imageName: String { /* ... */ }
 }
 
 class AIService: ObservableObject {
 static let shared = AIService() // Or your actual shared instance
 @Published var isLoading: Bool = false // If AIService exposes loading state
 
 func generateDailyMessage(user: User?, mascot: Mascot, completion: @escaping (Result<String, Error>) -> Void) {
 // Actual implementation talks to backend/AI model
 print("AI Service: Generating message for \(mascot)...")
 // Simulate network call & response
 DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
 if Bool.random() { // Simulate success/failure
 completion(.success("来自 \(mascot.rawValue) 的 AI 问候！"))
 } else {
 completion(.failure(NSError(domain: "AIServiceError", code: 500, userInfo: [NSLocalizedDescriptionKey: "服务暂时不可用"])))
 }
 }
 }
 }
 
 class AuthService: ObservableObject {
 static let shared = AuthService()
 @Published var currentUser: User? = User(name: "预览用户") // Mock user
 }
 
 struct User { // Basic user struct
 var name: String
 }
 
 // --- End Assumed definitions ---
 */