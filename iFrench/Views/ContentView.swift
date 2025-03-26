//
//  ContentView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// Import local modules
import Foundation

struct ContentView: View {
    @StateObject private var settings = AppSettings()
    
    var body: some View {
        // Using NavigationStack instead of NavigationView which is deprecated
        NavigationStack {
            DashboardView(settings: settings)
        }
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .dynamicTypeSize(settings.textSize.dynamicTypeSize)
    }
} 