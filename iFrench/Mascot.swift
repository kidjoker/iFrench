//
//  Mascot.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// Define app mascot
enum Mascot: String, CaseIterable, Identifiable {
    case frog = "青蛙"
    case owl = "猫头鹰"
    case fox = "狐狸"
    
    var id: String { self.rawValue }
    
    var imageName: String {
        switch self {
        case .frog: return "mascot-frog"
        case .owl: return "mascot-owl"
        case .fox: return "mascot-fox"
        }
    }
    
    var description: String {
        switch self {
        case .frog: return "活泼开朗，擅长发音练习和口语对话训练。"
        case .owl: return "睿智冷静，擅长词汇学习和语法规则讲解。"
        case .fox: return "机智灵活，擅长听力练习和文化知识讲解。"
        }
    }
}
