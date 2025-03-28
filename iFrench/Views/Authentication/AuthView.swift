import SwiftUI

// Import required components
import SwiftUI

// Reference to other files in the app
// ContentView.swift - Contains the main app UI
// AppSettings.swift - Contains app settings and preferences
// AuthService.swift - Authentication service
// LoginView.swift - Login screen UI

struct AuthView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.authState == .authenticated {
                // User is authenticated, show main app content
                ContentView(settings: AppSettings())
                    .environmentObject(authService)
            } else {
                // User is not authenticated, show login screen
                LoginView()
                    .environmentObject(authService)
            }
        }
        .animation(.easeInOut, value: authService.authState)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
} 