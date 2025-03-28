//
//  ContentView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// Import local modules
import Foundation

/// Main content view after authentication
struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        NavigationView {
            DashboardView(settings: settings)
        }
        .environmentObject(authService)
    }
}

/// Home view content
// Remove everything from here to the end of file

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(settings: AppSettings())
            .environmentObject(AuthService.shared)
    }
} 