//
//  iFrenchApp.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI
// Import AuthService and AuthView
import SwiftUI

// Add ContentView for now until we fully implement AuthView
@main
struct iFrenchApp: App {
    // Create a shared AppSettings instance
    @StateObject private var settings = AppSettings()
    // Use the shared AuthService instance
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    // 用户已登录，显示主内容
                    ContentView(settings: settings)
                        .environmentObject(authService)
                } else {
                    // 用户未登录，显示登录界面
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .animation(.easeInOut, value: authService.authState)
        }
    }
}
