//
//  ListeningExercise.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

/// 听力练习模型
struct ListeningExercise: Identifiable, Hashable {
    /// 唯一标识符
    let id: String
    
    /// 练习标题
    let title: String
    
    /// 音频文件名
    let audioFileName: String
    
    /// 音频长度（秒）
    let audioLength: Double
    
    /// 文本内容
    let transcript: String
    
    /// 问题列表
    var questions: [ListeningQuestion]
    
    /// 原始问题（保持向后兼容）
    let question: String
    
    /// 原始选项（保持向后兼容）
    let options: [String]
    
    /// 原始正确选项索引（保持向后兼容）
    let correctOptionIndex: Int
    
    /// 难度级别
    let difficulty: Difficulty
    
    /// 练习类型
    let type: ExerciseType
    
    /// 用户选择的选项索引
    var userSelected: Int?
    
    /// 标记的时间戳列表（例如生词、重要点等）
    var markedTimestamps: [Double]
    
    /// 音频URL，基于音频文件名计算
    var audioURL: URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectory = documentsDirectory.appendingPathComponent("AudioFiles", isDirectory: true)
        return audioDirectory.appendingPathComponent(audioFileName)
    }
    
    /// 创建一个带有问题的新实例
    init(title: String, audioFileName: String, audioLength: Double, transcript: String, question: String, options: [String], correctOptionIndex: Int, difficulty: Difficulty, type: ExerciseType, userSelected: Int? = nil, markedTimestamps: [Double] = []) {
        self.id = UUID().uuidString
        self.title = title
        self.audioFileName = audioFileName
        self.audioLength = audioLength
        self.transcript = transcript
        self.question = question
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.difficulty = difficulty
        self.type = type
        self.userSelected = userSelected
        self.markedTimestamps = markedTimestamps
        
        // 创建默认问题
        self.questions = [
            ListeningQuestion(
                id: UUID().uuidString,
                question: question,
                options: options,
                correctOptionIndex: correctOptionIndex,
                difficulty: difficulty,
                userSelected: userSelected
            )
        ]
    }
    
    /// 使用已有ID创建实例（用于重新加载）
    init(id: String, title: String, audioFileName: String, audioLength: Double, transcript: String, question: String, options: [String], correctOptionIndex: Int, difficulty: Difficulty, type: ExerciseType, userSelected: Int? = nil, markedTimestamps: [Double] = [], questions: [ListeningQuestion] = []) {
        self.id = id
        self.title = title
        self.audioFileName = audioFileName
        self.audioLength = audioLength
        self.transcript = transcript
        self.question = question
        self.options = options
        self.correctOptionIndex = correctOptionIndex
        self.difficulty = difficulty
        self.type = type
        self.userSelected = userSelected
        self.markedTimestamps = markedTimestamps
        
        if questions.isEmpty {
            // 如果没有提供问题，创建一个默认问题
            self.questions = [
                ListeningQuestion(
                    id: UUID().uuidString,
                    question: question,
                    options: options,
                    correctOptionIndex: correctOptionIndex,
                    difficulty: difficulty,
                    userSelected: userSelected
                )
            ]
        } else {
            self.questions = questions
        }
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