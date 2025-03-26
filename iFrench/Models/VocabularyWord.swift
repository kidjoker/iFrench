//
//  VocabularyWord.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI
import Foundation

// 词汇模型
struct VocabularyWord: Identifiable {
    let id = UUID()
    let french: String
    let chinese: String
    let phonetic: String
    var difficulty: Int // 1-5, 5 being most difficult
    var nextReviewDate: Date
    var isStarred: Bool = false
    
    // Spaced repetition calculation
    mutating func updateNextReview(quality: Int) {
        // quality: 0-5, 0 being completely forgot, 5 being perfect recall
        // Implementation of SM-2 spaced repetition algorithm (simplified)
        let _ = max(1.3, 2.5 - 0.2 * Double(5 - quality))
        let interval: TimeInterval
        
        if quality < 3 {
            // If recall was difficult, reset to short interval
            interval = 24 * 60 * 60 // 1 day in seconds
            difficulty = min(5, difficulty + 1)
        } else {
            // Calculate new interval based on difficulty and quality
            let multiplier = Double(quality) * 0.4 + 1.0
            let daysToAdd = Double(difficulty <= 3 ? difficulty : 3) * multiplier
            interval = daysToAdd * 24 * 60 * 60
            difficulty = max(1, difficulty - 1)
        }
        
        nextReviewDate = Date().addingTimeInterval(interval)
    }
} 