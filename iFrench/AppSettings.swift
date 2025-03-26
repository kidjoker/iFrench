//
//  AppSettings.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// MARK: - App Settings
class AppSettings: ObservableObject {
    enum TextSize: String, CaseIterable, Identifiable {
        case small = "小"
        case medium = "中"
        case large = "大"
        
        var id: String { self.rawValue }
        
        var fontScaleFactor: CGFloat {
            switch self {
            case .small: return 0.9
            case .medium: return 1.0
            case .large: return 1.2
            }
        }
        
        var dynamicTypeSize: DynamicTypeSize {
            switch self {
            case .small: return .small
            case .medium: return .medium
            case .large: return .large
            }
        }
    }
    
    // 应用设置
    @Published var isDarkMode: Bool = false
    @Published var textSize: TextSize = .medium
    @Published var selectedMascot: Mascot = .frog
}
