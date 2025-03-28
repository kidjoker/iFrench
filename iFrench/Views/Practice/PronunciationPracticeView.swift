//
//  PronunciationPracticeView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct PronunciationPracticeView: View {
    // 发音练习数据
    struct PronunciationWord: Identifiable {
        let id = UUID()
        let french: String
        let phonetic: String
        let chinese: String
        let difficultyLevel: Int // 1-5
    }
    
    struct Recording: Identifiable {
        let id = UUID()
        let timestamp: Date
        let score: Double
    }
    
    // 测试数据
    private let words = [
        PronunciationWord(french: "Bonjour", phonetic: "bɔ̃.ʒuʁ", chinese: "你好", difficultyLevel: 1),
        PronunciationWord(french: "Je m'appelle", phonetic: "ʒə ma.pɛl", chinese: "我叫…", difficultyLevel: 2),
        PronunciationWord(french: "Comment allez-vous", phonetic: "kɔ.mɑ̃t‿a.le vu", chinese: "你好吗", difficultyLevel: 3),
        PronunciationWord(french: "Au revoir", phonetic: "o ʁə.vwaʁ", chinese: "再见", difficultyLevel: 1),
        PronunciationWord(french: "S'il vous plaît", phonetic: "sil vu plɛ", chinese: "请", difficultyLevel: 2)
    ]
    
    @State private var currentIndex = 0
    @State private var pronunciationScore: Double = 0.0
    @State private var showFeedback = false
    @State private var isRecording = false
    @State private var problemPhonemes: [String] = []
    @State private var currentAttempt = 0
    @State private var recordings: [UUID: [Recording]] = [:]
    
    private var currentWord: PronunciationWord {
        words[currentIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 头部导航
            HStack {
                Button(action: {
                    if currentIndex > 0 {
                        navigateToWord(index: currentIndex - 1)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(currentIndex > 0 ? .blue : .gray)
                }
                .disabled(currentIndex == 0)
                
                Spacer()
                
                Text("\(currentIndex + 1)/\(words.count)")
                    .font(.subheadline)
                
                Spacer()
                
                Button(action: {
                    if currentIndex < words.count - 1 {
                        navigateToWord(index: currentIndex + 1)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(currentIndex < words.count - 1 ? .blue : .gray)
                }
                .disabled(currentIndex == words.count - 1)
            }
            .padding(.horizontal)
            
            // 单词展示卡片
            VStack(spacing: 15) {
                // 法语单词
                Text(currentWord.french)
                    .font(.system(size: 36, weight: .bold))
                
                // 音标
                Text(currentWord.phonetic)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // 中文意思
                Text(currentWord.chinese)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
                // 难度指示器
                HStack {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= currentWord.difficultyLevel ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 5)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            .padding(.horizontal)
            
            // 录音按钮
            if !showFeedback {
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                            .shadow(color: (isRecording ? Color.red : Color.blue).opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 20)
                
                Text(isRecording ? "正在录音..." : "点击麦克风开始录音")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
            } else {
                // 反馈界面
                VStack(spacing: 20) {
                    // 得分
                    ZStack {
                        Circle()
                            .stroke(scoreColor, lineWidth: 10)
                            .opacity(0.3)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(pronunciationScore))
                            .stroke(scoreColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("\(Int(pronunciationScore * 100))")
                                .font(.system(size: 36, weight: .bold))
                            
                            Text("分")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 鼓励信息
                    Text(getEncouragementMessage())
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // 问题音素
                    if !problemPhonemes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("需要注意的音素:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(problemPhonemes, id: \.self) { phoneme in
                                HStack(alignment: .top) {
                                    Text(phoneme)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.red)
                                        .frame(width: 30)
                                    
                                    Text(getTipForPhoneme(phoneme))
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // 操作按钮
                    HStack(spacing: 20) {
                        Button(action: {
                            showFeedback = false
                            currentAttempt += 1
                        }) {
                            Text("再试一次")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if currentIndex < words.count - 1 {
                                navigateToWord(index: currentIndex + 1)
                            } else {
                                // 完成所有单词
                            }
                        }) {
                            Text("下一个")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            
            // 历史记录
            if let wordRecordings = recordings[currentWord.id], !wordRecordings.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("历史记录")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(wordRecordings) { recording in
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Text("\(Int(recording.score * 100))")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(recording.score >= 0.8 ? .green : (recording.score >= 0.6 ? .orange : .red))
                                    }
                                    
                                    Text(recording.timestamp, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            Spacer()
        }
        .navigationTitle("发音练习")
        #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .padding(.vertical)
    }
    
    // Helper computed properties
    var scoreColor: Color {
        if pronunciationScore >= 0.8 {
            return .green
        } else if pronunciationScore >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Helper methods
    private func startRecording() {
        isRecording = true
        
        // Simulating speech recognition start
        // In a real app, you'd use SFSpeechRecognizer here
    }
    
    private func stopRecording() {
        isRecording = false
        
        // Simulate speech recognition result
        // In a real app, you'd process the speech recognition result here
        simulateRecognitionResult()
    }
    
    private func simulateRecognitionResult() {
        // Simulate a random score between 0.3 and 1.0
        // In a real app, this would come from actual speech recognition
        pronunciationScore = Double.random(in: 0.3...1.0)
        
        // Identify problem phonemes if score is low
        problemPhonemes = []
        if pronunciationScore < 0.8 {
            // In a real app, these would be identified from actual pronunciation issues
            let allPhonemes = currentWord.phonetic.components(separatedBy: ".")
            let selectedCount = Int.random(in: 1...min(2, allPhonemes.count))
            
            for _ in 0..<selectedCount {
                if let phoneme = allPhonemes.randomElement() {
                    problemPhonemes.append(phoneme)
                }
            }
        }
        
        // Record this attempt
        let recording = Recording(timestamp: Date(), score: pronunciationScore)
        if var wordRecordings = recordings[currentWord.id] {
            wordRecordings.append(recording)
            recordings[currentWord.id] = wordRecordings
        } else {
            recordings[currentWord.id] = [recording]
        }
        
        showFeedback = true
    }
    
    private func navigateToWord(index: Int) {
        currentIndex = index
        showFeedback = false
        problemPhonemes = []
        currentAttempt = 0
    }
    
    private func getTipForPhoneme(_ phoneme: String) -> String {
        // In a real app, you'd provide actual pronunciation tips
        switch phoneme {
        case "ʒ":
            return "发音类似于汉语中的\"日\"，但嘴型更圆"
        case "ʁ":
            return "法语r音，舌根摩擦声，位于喉部"
        case "ɛ̃":
            return "鼻腔元音，嘴型扁平，气流通过鼻腔"
        case "ɔ̃":
            return "圆唇鼻腔元音，嘴唇向前突出"
        case "y":
            return "圆唇前元音，嘴唇呈圆形，舌位高前"
        default:
            return "试着模仿标准发音"
        }
    }
    
    private func getEncouragementMessage() -> String {
        if pronunciationScore >= 0.9 {
            return "太棒了！你的发音非常准确！"
        } else if pronunciationScore >= 0.8 {
            return "很好！继续保持！"
        } else if pronunciationScore >= 0.6 {
            return "不错的尝试，再练习一下就更好了！"
        } else {
            return "再多练习几次，你一定能进步！"
        }
    }
    
    private func calculateAverageScore() -> Double {
        var totalScore = 0.0
        var count = 0
        
        for (_, wordRecordings) in recordings {
            if let bestScore = wordRecordings.map({ $0.score }).max() {
                totalScore += bestScore
                count += 1
            }
        }
        
        return count > 0 ? totalScore / Double(count) : 0.0
    }
} 