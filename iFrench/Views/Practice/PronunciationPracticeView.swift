//
//  PronunciationPracticeView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

// MARK: - Data Models
/// Represents a word or phrase for pronunciation practice.
struct PronunciationWord: Identifiable {
    let id = UUID()
    let french: String
    let phonetic: String
    let chinese: String
    let difficultyLevel: Int // 1-5
}

/// Represents a single recorded attempt for a word.
struct Recording: Identifiable {
    let id = UUID()
    let timestamp: Date
    let score: Double // 0.0 to 1.0
}

/// Represents the different states the practice view can be in.
enum PracticeState {
    case idle       // Waiting to record
    case recording  // Currently recording audio
    case feedback   // Showing feedback after recording
}

// MARK: - PronunciationPracticeView Definition
/// A view for practicing French pronunciation with immediate feedback.
struct PronunciationPracticeView: View {

    // MARK: - Properties

    // Mock data - replace with data from a service or data store
    private let words = [
        PronunciationWord(french: "Bonjour", phonetic: "bɔ̃.ʒuʁ", chinese: "你好", difficultyLevel: 1),
        PronunciationWord(french: "Je m'appelle", phonetic: "ʒə ma.pɛl", chinese: "我叫…", difficultyLevel: 2),
        PronunciationWord(french: "Comment allez-vous", phonetic: "kɔ.mɑ̃t‿a.le vu", chinese: "你好吗", difficultyLevel: 3),
        PronunciationWord(french: "Au revoir", phonetic: "o ʁə.vwaʁ", chinese: "再见", difficultyLevel: 1),
        PronunciationWord(french: "S'il vous plaît", phonetic: "sil vu plɛ", chinese: "请", difficultyLevel: 2)
    ]

    @State private var currentIndex = 0
    @State private var currentPracticeState: PracticeState = .idle
    @State private var pronunciationScore: Double = 0.0 // Score from 0.0 to 1.0
    @State private var problemPhonemes: [String] = []
    @State private var recordings: [UUID: [Recording]] = [:] // Word ID -> Recordings

    /// Computed property for the currently displayed word.
    private var currentWord: PronunciationWord {
        words[currentIndex]
    }

    /// Computed property for the score color based on the result.
    private var scoreColor: Color {
        switch pronunciationScore {
        case ..<0.6: .red
        case ..<0.8: .orange
        default: .green
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 and manage padding internally
            // Header Navigation
            headerNavigation

            ScrollView {
                VStack(spacing: 20) { // Main content stack
                    wordCard
                    practiceArea // Contains recording button or feedback
                    historySection
                }
                .padding(.vertical) // Vertical padding for scroll content
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea(.container, edges: .bottom)) // Adaptive background
        .navigationTitle("发音练习")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    /// Header view with navigation arrows and progress indicator.
    private var headerNavigation: some View {
        HStack {
            // Previous Button
            Button { navigateToWord(index: currentIndex - 1) } label: {
                Image(systemName: "chevron.left")
            }
            .font(.title2)
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.3 : 1.0) // Visual disabled state

            Spacer()
            Text("\(currentIndex + 1) / \(words.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()

            // Next Button
            Button { navigateToWord(index: currentIndex + 1) } label: {
                Image(systemName: "chevron.right")
            }
            .font(.title2)
            .disabled(currentIndex == words.count - 1)
            .opacity(currentIndex == words.count - 1 ? 0.3 : 1.0)
        }
        .padding()
        .background(.regularMaterial) // Use material background for header
    }

    /// Card displaying the current word details.
    private var wordCard: some View {
        VStack(spacing: 15) {
            Text(currentWord.french)
                .font(.system(size: 36, weight: .bold))

            Text(currentWord.phonetic)
                .font(.title3)
                .foregroundColor(.secondary)

            Text(currentWord.chinese)
                .font(.headline)
                .foregroundColor(.gray) // Keep gray or use .secondary
                .padding(.top, 5)

            // Difficulty Indicator
            HStack {
                ForEach(1...5, id: \.self) { level in
                    Circle()
                        .fill(level <= currentWord.difficultyLevel ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 5)
        }
        .padding(20) // Increase padding slightly
        .frame(maxWidth: .infinity)
        .background(.regularMaterial) // Use material background
        .cornerRadius(15)
        .shadow(color: .primary.opacity(0.06), radius: 8, x: 0, y: 2) // Adaptive shadow
        .padding(.horizontal)
    }

    /// Area containing the recording button or the feedback view.
    @ViewBuilder
    private var practiceArea: some View {
        switch currentPracticeState {
        case .idle:
            recordButtonView
        case .recording:
            recordButtonView // Can show a different state if needed (e.g., pulsing)
        case .feedback:
            feedbackView
        }
    }

    /// The microphone button view for starting/stopping recording.
    private var recordButtonView: some View {
        VStack(spacing: 10) { // Reduced spacing
            Button {
                if currentPracticeState == .recording {
                    stopRecording()
                } else {
                    startRecording()
                }
            } label: {
                ZStack {
                    // Base circle
                    Circle()
                        .fill(currentPracticeState == .recording ? Color.red : Color.accentColor)
                        .frame(width: 80, height: 80)
                        .shadow(color: (currentPracticeState == .recording ? Color.red : Color.accentColor).opacity(0.4), radius: 10, x: 0, y: 5)

                    // Icon
                    Image(systemName: currentPracticeState == .recording ? "stop.fill" : "mic.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                // Add pulsing animation when recording?
                 .scaleEffect(currentPracticeState == .recording ? 1.05 : 1.0)
            }
             .animation(.spring(response: 0.3, dampingFraction: 0.5), value: currentPracticeState) // Animate button state change

            Text(currentPracticeState == .recording ? "正在录音..." : "点击麦克风开始录音")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }

    /// View displaying the pronunciation score and feedback.
    private var feedbackView: some View {
        VStack(spacing: 25) { // Increased spacing in feedback
            scoreCircle
            encouragementMessage

            if !problemPhonemes.isEmpty {
                problemPhonemesSection
            }

            actionButtons
        }
        .padding() // Padding around the entire feedback content
    }

    /// Circular view displaying the pronunciation score.
    private var scoreCircle: some View {
        ZStack {
            Circle()
                .stroke(scoreColor.opacity(0.3), lineWidth: 12) // Thicker background stroke

            Circle()
                .trim(from: 0, to: CGFloat(pronunciationScore))
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: pronunciationScore) // Animate score change

            VStack {
                Text("\(Int(pronunciationScore * 100))")
                    .font(.system(size: 40, weight: .bold))
                Text("分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 130, height: 130) // Slightly larger score circle
    }

    /// Text displaying an encouraging message based on the score.
    private var encouragementMessage: some View {
        Text(getEncouragementMessage())
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    /// Section listing problematic phonemes and tips.
    private var problemPhonemesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("需要注意的音素:")
                .font(.subheadline.weight(.semibold))

            // Use Grid for better alignment if tips vary in length
            ForEach(problemPhonemes, id: \.self) { phoneme in
                HStack(alignment: .top) {
                    Text(phoneme)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                        .frame(minWidth: 40, alignment: .leading) // Ensure alignment

                    Text(getTipForPhoneme(phoneme))
                        .font(.subheadline)
                        .foregroundColor(.primary) // Use primary for readability
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.08)) // Subtle background
        .cornerRadius(10)
        .padding(.horizontal)
    }

    /// Buttons for "Try Again" and "Next".
    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button("再试一次") {
                // Reset state for retry
                currentPracticeState = .idle
                problemPhonemes = []
                // Keep currentAttempt logic if needed elsewhere, otherwise remove
            }
            .buttonStyle(.borderedProminent) // Use standard button styles
            .tint(.accentColor)

            Button("下一个") {
                navigateToWord(index: currentIndex + 1)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(currentIndex == words.count - 1)
            .opacity(currentIndex == words.count - 1 ? 0.5 : 1.0)
        }
    }

    /// Horizontal scroll view showing recording history for the current word.
    @ViewBuilder
    private var historySection: some View {
        if let wordRecordings = recordings[currentWord.id], !wordRecordings.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("历史记录")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(wordRecordings) { recording in
                            historyItem(for: recording)
                        }
                    }
                    .padding(.horizontal) // Padding for scroll content
                }
            }
            .padding(.bottom) // Add padding below history
        }
    }

    /// View for a single item in the recording history.
    private func historyItem(for recording: Recording) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.1)) // Use secondary opacity
                    .frame(width: 50, height: 50)

                Text("\(Int(recording.score * 100))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(scoreColor(for: recording.score)) // Use helper
            }

            Text(recording.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helper Methods

    /// Starts the recording process (simulation).
    private func startRecording() {
        currentPracticeState = .recording
        // TODO: Add actual audio recording logic (e.g., AVAudioRecorder)
        print("Recording started...")
    }

    /// Stops the recording process and simulates analysis.
    private func stopRecording() {
        // TODO: Stop actual audio recording here
        print("Recording stopped.")
        simulateRecognitionResult() // Process the (simulated) recording
    }

    /// Simulates receiving a score and identifying problem phonemes.
    private func simulateRecognitionResult() {
        // Simulate a score (replace with actual speech analysis result)
        pronunciationScore = Double.random(in: 0.4...1.0)

        // Simulate phoneme analysis (replace with actual analysis)
        problemPhonemes = []
        if pronunciationScore < 0.8 {
            let allPhonemes = currentWord.phonetic.components(separatedBy: CharacterSet(charactersIn: ". ")) // Split by dot or space
            let uniquePhonemes = Set(allPhonemes.filter { !$0.isEmpty })
            let selectedCount = Int.random(in: 1...min(2, uniquePhonemes.count))
            problemPhonemes = Array(uniquePhonemes.shuffled().prefix(selectedCount))
        }

        // Record this attempt
        let recording = Recording(timestamp: Date(), score: pronunciationScore)
        recordings[currentWord.id, default: []].append(recording)

        // Transition to feedback state
        currentPracticeState = .feedback
    }

    /// Navigates to a specific word index and resets the state.
    private func navigateToWord(index: Int) {
        guard index >= 0 && index < words.count else { return }
        currentIndex = index
        currentPracticeState = .idle
        problemPhonemes = []
        // Reset score display, but keep history
        pronunciationScore = 0
    }

    /// Provides mock tips for given phonemes. Replace with real tips.
    private func getTipForPhoneme(_ phoneme: String) -> String {
        switch phoneme {
        case "ʒ": return "发音类似于汉语中的\"日\"，但嘴型更圆。"
        case "ʁ": return "法语 r 音，舌根摩擦声，位于喉部。"
        case "ɛ̃", "ɛ": return "鼻腔元音 'ɛ̃' (如 vin)，嘴型扁平，气流通过鼻腔。非鼻音 'ɛ' (如 mère) 则不通过鼻腔。"
        case "ɔ̃", "ɔ": return "圆唇鼻腔元音 'ɔ̃' (如 bon)，嘴唇前突。非鼻音 'ɔ' (如 bonne) 则不通过鼻腔。"
        case "y": return "圆唇前元音 (如 tu)，嘴唇呈圆形，舌位高前。"
        case "ø": return "圆唇前元音 (如 peu)，介于 'e' 和 'o' 之间。"
        case "œ": return "圆唇前元音 (如 sœur)，比 'ø' 更开口。"
        case "ɑ̃": return "鼻腔元音 (如 an)，嘴巴张开，气流送至鼻腔。"
        case "bɔ̃": return "注意鼻音 /ɔ̃/。"
        case "ʒuʁ": return "注意 /ʒ/ 和喉音 /ʁ/。"
        case "mapɛl": return "注意 /p/ 和 /l/ 的清晰度。"
        case "kɔmɑ̃t‿ale": return "注意连诵 /t‿a/ 和元音 /ɑ̃/。"
        case "vu": return "注意元音 /u/。"
        case "o": return "注意元音 /o/。"
        case "ʁəvwaʁ": return "注意两个 /ʁ/ 音和 /v/。"
        case "sil": return "注意 /s/ 和 /l/。"
        case "plɛ": return "注意辅音连缀 /pl/ 和元音 /ɛ/。"
        default: return "多听多模仿标准发音。"
        }
    }

    /// Returns an encouraging message based on the score.
    private func getEncouragementMessage() -> String {
        switch pronunciationScore {
        case ..<0.6: return "再多练习几次，你一定能进步！"
        case ..<0.8: return "不错的尝试，再练习一下就更好了！"
        case ..<0.9: return "很好！继续保持！"
        default: return "太棒了！你的发音非常准确！"
        }
    }

    /// Helper to get score color for history items.
    private func scoreColor(for score: Double) -> Color {
        switch score {
        case ..<0.6: .red
        case ..<0.8: .orange
        default: .green
        }
    }
}

// MARK: - Preview
#Preview {
    // Wrap in NavigationStack for preview context
    NavigationStack {
        PronunciationPracticeView()
    }
} 