//
//  AppSettings.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import Foundation
import SwiftUI

/// App configuration and user preferences
class AppSettings: ObservableObject {
    /// Theme preference (light, dark, system)
    @Published var theme: AppTheme = .system {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        }
    }
    
    /// Notification preferences
    @Published var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    /// Language preference
    @Published var language: AppLanguage = .english {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "language")
        }
    }
    
    /// Font size preference
    @Published var fontSize: FontSize = .medium {
        didSet {
            UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
        }
    }
    
    /// App version
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    /// Mascot preference
    @Published var selectedMascot: Mascot = .frog {
        didSet {
            UserDefaults.standard.set(selectedMascot.rawValue, forKey: "selectedMascot")
        }
    }
    
    /// Initialize with saved settings or defaults
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.theme = theme
        }
        
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        if let savedLanguage = UserDefaults.standard.string(forKey: "language"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.language = language
        }
        
        if let savedFontSize = UserDefaults.standard.string(forKey: "fontSize"),
           let fontSize = FontSize(rawValue: savedFontSize) {
            self.fontSize = fontSize
        }
        
        if let savedMascot = UserDefaults.standard.string(forKey: "selectedMascot"),
           let mascot = Mascot(rawValue: savedMascot) {
            self.selectedMascot = mascot
        }
    }
    
    /// Reset all settings to default values
    func resetToDefaults() {
        self.theme = .system
        self.notificationsEnabled = true
        self.language = .english
        self.fontSize = .medium
        self.selectedMascot = .frog
    }
}

/// App theme options
enum AppTheme: String {
    case light
    case dark
    case system
}

/// App language options
enum AppLanguage: String {
    case english = "en"
    case french = "fr"
    case spanish = "es"
    case chinese = "zh"
}

/// Font size options
enum FontSize: String {
    case small
    case medium
    case large
    case extraLarge
    
    /// Get the actual font size based on preference
    var size: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        }
    }
} 