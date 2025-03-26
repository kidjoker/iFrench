//
//  ListeningExercise.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// 模拟听力练习数据
struct ListeningExercise: Identifiable {
    let id = UUID()
    let title: String
    let audioFileName: String
    let audioLength: TimeInterval
    let transcript: String
    let question: String
    let options: [String]
    let correctOptionIndex: Int
    var userSelected: Int? = nil
    let difficulty: Difficulty
    let type: ExerciseType
    var markedTimestamps: [TimeInterval] = []
    
    init(title: String, audioFileName: String, audioLength: TimeInterval, transcript: String, 
         question: String, options: [String], correctOptionIndex: Int, difficulty: Difficulty, 
         type: ExerciseType, userSelected: Int? = nil, markedTimestamps: [TimeInterval] = []) {
        self.title = title
        self.audioFileName = audioFileName
        self.audioLength = audioLength
        self.transcript = transcript
        self.question = question
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.userSelected = userSelected
        self.difficulty = difficulty
        self.type = type
        self.markedTimestamps = markedTimestamps
    }
    
    enum Difficulty: String, CaseIterable {
        case beginner = "初级"
        case intermediate = "中级"
        case advanced = "高级"
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
    
    enum ExerciseType: String {
        case precision = "精听"
        case extensive = "泛听"
        case listenRepeat = "听说跟读"
    }
} 