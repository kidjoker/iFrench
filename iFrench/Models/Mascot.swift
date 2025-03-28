//
//  Mascot.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import Foundation
import SwiftUI

/// Represents the different mascots available in the app
enum Mascot: String, CaseIterable, Identifiable {
    case frog = "小蛙"
    case owl = "猫头鹰"
    case fox = "小狐狸"
    
    /// Unique identifier for each mascot
    var id: String { rawValue }
    
    /// Description of each mascot
    var description: String {
        switch self {
        case .frog:
            return "活泼开朗，帮助你一步步学习法语"
        case .owl:
            return "睿智沉稳，提供专业的语法讲解"
        case .fox:
            return "聪明机灵，让学习变得有趣"
        }
    }
    
    /// Color associated with each mascot
    var color: Color {
        switch self {
        case .frog: return .green
        case .owl: return .brown
        case .fox: return .orange
        }
    }
} 