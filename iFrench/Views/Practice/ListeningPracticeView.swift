//
//  ListeningPracticeView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI
import AVFoundation

/// A view for practicing French listening comprehension with audio exercises.
@MainActor
struct ListeningPracticeView: View {
    // MARK: - State Objects and Environment
    @StateObject private var listeningService = ListeningService.shared
    // @StateObject private var deepSeekService = DeepSeekService.shared // Assuming not used directly in this refactor pass
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - State Variables
    @State private var showingTranscript = false
    @State private var showingAnswer = false
    // @State private var isRecording = false // Assuming not used currently
    // @State private var showingAnalysis = false // Assuming AnalysisView is presented differently or not yet implemented
    // @State private var showingRecommendations = false // Assuming not used currently
    @State private var showingImporter = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingDownloadSheet = false

    // MARK: - Body
    /// The main content of the statistics view.
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView

            // Main Content Area
            Group { // Use Group for conditional content clarity
                if listeningService.isLoading && listeningService.exercises.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if listeningService.exercises.isEmpty {
                    emptyStateView
                } else {
                    contentScrollView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure content fills space
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom)) // Background for the whole view area
        .navigationBarHidden(true) // Hide default navigation bar as we have a custom header
        // MARK: - Modifiers (Sheets, Alerts, Overlays)
        .sheet(isPresented: $showingTranscript, content: transcriptSheet)
        .sheet(isPresented: $showingDownloadSheet, content: downloadSheet)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false,
            onCompletion: handleFileImport
        )
        .alert("错误", isPresented: $showingError, actions: { // Simplified Alert
            Button("确定", role: .cancel) {}
        }, message: {
            Text(errorMessage)
        })
        .onReceive(listeningService.$error) { error in // React to errors from service
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showingError = true
            }
        }
        .overlay(loadingOverlay) // Consolidated loading overlay
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("听力练习")
                .font(.title2.bold())
            Spacer()
            importMenu
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.regularMaterial) // Use material for adaptive background
        .overlay(Divider(), alignment: .bottom) // Subtle separator
    }

    /// Menu for importing audio files or from YouTube.
    private var importMenu: some View {
        Menu {
            Button { showingImporter = true } label: {
                Label("导入本地音频", systemImage: "square.and.arrow.down")
            }
            Button { showingDownloadSheet = true } label: {
                Label("从YouTube导入", systemImage: "play.rectangle.fill") // Use Label
            }
        } label: {
            Image(systemName: "plus.circle.fill") // Use filled circle icon
                .font(.title2) // Slightly larger icon
                .foregroundColor(.accentColor) // Use accent color
        }
    }

    // MARK: - Content Scroll View
    private var contentScrollView: some View {
        ScrollView {
            VStack(spacing: 24) { // Consistent spacing
                exerciseListView

                // Currently selected exercise details
                if let exercise = listeningService.currentExercise {
                    audioPlayerView(for: exercise)
                    questionSectionView(for: exercise)
                } else if listeningService.isLoading {
                    ProgressView().padding()
                }
            }
            .padding() // Padding around the scroll content
        }
        // No background needed here, parent VStack has it
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "headphones.circle") // Updated icon
                .font(.system(size: 60))
                .foregroundColor(.secondary) // Use semantic color
            Text("暂无听力练习")
                .font(.title3.bold())
            Text("点击右上角 '+' 添加本地音频或从YouTube导入")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Spacer() // Add more spacing towards bottom
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Exercise List
    private var exerciseListView: some View {
        VStack(alignment: .leading, spacing: 16) { // Increased spacing
            HStack {
                Text("练习列表")
                    .font(.headline)
                Spacer()
                Text("\(listeningService.exercises.count) 个练习")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // List of exercises
            ForEach(listeningService.exercises) { exercise in
                Button { listeningService.selectExercise(exercise) } label: {
                    exerciseRow(for: exercise)
                }
                .buttonStyle(.plain) // Ensure row acts as a single button
            }
        }
        // Removed background/cornerRadius, rows handle their styling
    }

    /// A single row representing a listening exercise in the list.
    private func exerciseRow(for exercise: ListeningExercise) -> some View {
        let isSelected = exercise.id == listeningService.currentExercise?.id

        return HStack(spacing: 12) {
            Image(systemName: "headphones")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isSelected ? .accentColor : .secondary)
                .frame(width: 40, height: 40)
                .background( (isSelected ? Color.accentColor : Color.secondary).opacity(0.1) , in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.subheadline.weight(.semibold)) // Slightly bolder title
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(exercise.difficulty.rawValue)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(difficultyColor(for: exercise.difficulty).opacity(0.15))
                        .foregroundColor(difficultyColor(for: exercise.difficulty))
                        .clipShape(Capsule()) // Use Capsule shape

                    Text(formatDuration(exercise.audioLength))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Status indicator (correct/incorrect)
            if let selected = exercise.userSelected {
                Image(systemName: selected == exercise.correctOptionIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(selected == exercise.correctOptionIndex ? .green : .red)
                    .font(.title3) // Make status icon slightly larger
            }
        }
        .padding(12)
        .background(.regularMaterial) // Use material for background
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2) // Thicker border for selection
        )
        // Shadow can be removed when using material, or kept subtle
        // .shadow(color: .primary.opacity(0.05), radius: 3, x: 0, y: 1)
    }

    // MARK: - Audio Player
    @ViewBuilder
    private func audioPlayerView(for exercise: ListeningExercise) -> some View {
        VStack(spacing: 16) {
            // Title and Close Button
            HStack {
                Text(exercise.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Button { listeningService.selectExercise(nil) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary.opacity(0.6))
                }
            }

            // Progress Slider and Time Labels
            VStack(spacing: 4) {
                Slider(value: Binding( // Use Binding for two-way interaction
                    get: { listeningService.progress },
                    set: { listeningService.seekToPosition($0) }
                ))
                .tint(.accentColor) // Use accent color for slider

                HStack {
                    Text(formatTime(listeningService.currentTime)).font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text(formatTime(exercise.audioLength)).font(.caption2).foregroundColor(.secondary)
                }
            }

            // Playback Controls
            HStack(spacing: 35) { // Adjusted spacing
                Button { listeningService.backward() } label: {
                    Image(systemName: "gobackward.10").font(.title).foregroundColor(.primary)
                }
                Button { listeningService.isPlaying ? listeningService.pause() : listeningService.play() } label: {
                    Image(systemName: listeningService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50)) // Larger play/pause button
                        .foregroundColor(.accentColor)
                }
                Button { listeningService.forward() } label: {
                    Image(systemName: "goforward.10").font(.title).foregroundColor(.primary)
                }
            }
            .padding(.vertical, 8)

            // Action Buttons (Transcript/Answer)
            HStack(spacing: 12) {
                actionButton(title: "查看原文", icon: "doc.text", action: { showingTranscript = true })
                actionButton(title: showingAnswer ? "隐藏答案" : "查看答案", icon: showingAnswer ? "eye.slash" : "eye", action: { showingAnswer.toggle() })
            }
        }
        .padding()
        .background(.regularMaterial) // Use material
        .cornerRadius(16)
    }

    /// Helper for creating action buttons below the player.
    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity) // Make buttons fill available width
                .background(Color.primary.opacity(0.05)) // Subtle background
                .foregroundColor(.primary)
                .cornerRadius(10)
        }
    }


    // MARK: - Question Section
    @ViewBuilder
    private func questionSectionView(for exercise: ListeningExercise) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question Header
            HStack {
                Text("问题").font(.headline)
                Spacer()
                Button { Task { await regenerateQuestions(for: exercise) } } label: {
                    Label("重新生成", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption)
                }
                .tint(.accentColor) // Use tint for button color
            }

            // Question Text
            Text(exercise.question)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(0.05)) // Subtle background
                .cornerRadius(12)

            // Options
            VStack(spacing: 12) {
                ForEach(Array(exercise.options.enumerated()), id: \.offset) { index, option in
                    optionButton(option: option, index: index, exercise: exercise)
                }
            }

            // Answer Feedback & Analysis Link
            if let selectedIndex = exercise.userSelected {
                answerFeedbackView(selectedIndex: selectedIndex, exercise: exercise)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(.regularMaterial) // Use material
        .cornerRadius(16)
    }

    /// Button representing a single answer option.
    private func optionButton(option: String, index: Int, exercise: ListeningExercise) -> some View {
        let isSelected = exercise.userSelected == index
        let isCorrect = index == exercise.correctOptionIndex
        let showCorrect = showingAnswer && isCorrect
        let isWrong = isSelected && !isCorrect

        return Button { listeningService.submitAnswer(index) } label: {
            HStack {
                Text(option)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical) // Increase vertical padding
                    .padding(.leading) // Add leading padding

                // Status icon (shown after selection or when answer is revealed)
                if isWrong {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.red).padding(.trailing)
                } else if isSelected || showCorrect {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green).padding(.trailing)
                }
            }
            .background(
                // Background color changes based on state
                ZStack {
                    (isSelected || showCorrect) ? (isCorrect ? Color.green : Color.red).opacity(0.1) : Color.primary.opacity(0.05)
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((isSelected || showCorrect) ? (isCorrect ? Color.green : Color.red) : Color.clear, lineWidth: 1.5)
                }
            )
            .cornerRadius(12)
        }
        .disabled(exercise.userSelected != nil) // Disable after selection
    }

    /// View displaying feedback after an answer is submitted.
    private func answerFeedbackView(selectedIndex: Int, exercise: ListeningExercise) -> some View {
        let isCorrect = selectedIndex == exercise.correctOptionIndex
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("答案解析").font(.headline)
                Spacer()
                // Optional: Add 'View Analysis' button here if AnalysisView is used
                // Button("查看分析") { showingAnalysis = true }
            }
            Text(isCorrect ? "回答正确！" : "回答错误。正确答案是：\(exercise.options[exercise.correctOptionIndex])")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background((isCorrect ? Color.green : Color.red).opacity(0.1))
                .foregroundColor(isCorrect ? .green : .red)
                .cornerRadius(10)
        }
    }

    // MARK: - Sheets and Modals
    /// Content for the transcript sheet.
    private func transcriptSheet() -> some View {
        NavigationStack {
            if let exercise = listeningService.currentExercise {
                TranscriptView(transcript: exercise.transcript)
                    .navigationTitle("原文")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完成") { showingTranscript = false }
                        }
                    }
            }
        }
    }

    /// Content for the download sheet.
    private func downloadSheet() -> some View {
         DownloadFormView(isPresented: $showingDownloadSheet) { url, title in
             // Handle the download request
             Task {
                 do {
                     try await listeningService.downloadAudio(from: url, title: title.isEmpty ? nil : title, isYouTube: true)
                 } catch {
                     errorMessage = error.localizedDescription
                     showingError = true
                 }
             }
         }
     }

    // MARK: - Loading Overlay
     /// Consolidated overlay view for loading/processing states.
     @ViewBuilder
     private var loadingOverlay: some View {
         if listeningService.isLoading {
             ZStack {
                 // Semi-transparent background
                 Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)

                 VStack(spacing: 16) {
                     ProgressView().tint(.white).scaleEffect(1.5)

                     if listeningService.downloadProgress > 0 {
                         // Download Progress specific UI
                         VStack(spacing: 8) {
                             Text("\(Int(listeningService.downloadProgress * 100))%")
                                 .font(.title3.bold()).foregroundColor(.white)

                             ProgressView(value: listeningService.downloadProgress, total: 1.0)
                                 .tint(.accentColor) // Use accent color for progress bar
                                 .frame(width: 200)
                                 .scaleEffect(x: 1, y: 1.5, anchor: .center) // Make bar thicker

                             Text("下载中...").font(.subheadline).foregroundColor(.white.opacity(0.8))
                         }
                     } else {
                         // Generic Processing UI
                         Text("正在处理...").font(.headline).foregroundColor(.white)
                     }
                 }
                 .padding(30)
                 .background(.ultraThinMaterial) // Use material for the box background
                 .cornerRadius(20)
                 .shadow(color: .black.opacity(0.2), radius: 10) // Add shadow to the box
             }
             // Ensure overlay ignores safe area if needed, applied to the ZStack background
         }
     }

    // MARK: - Helper Functions & Callbacks

    /// Handles the result of the file importer.
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return } // Ensure a URL was selected
            Task {
                do {
                    try await listeningService.importAudio(from: url)
                } catch {
                    errorMessage = "导入失败: \(error.localizedDescription)"
                    showingError = true
                }
            }
        case .failure(let error):
            errorMessage = "文件选择失败: \(error.localizedDescription)"
            showingError = true
        }
    }

    /// Initiates regeneration of questions for the given exercise.
    private func regenerateQuestions(for exercise: ListeningExercise) async {
        do {
            try await listeningService.regenerateQuestions(for: exercise)
        } catch {
            errorMessage = "重新生成问题失败: \(error.localizedDescription)"
            showingError = true
        }
    }

    /// Formats time interval (seconds) into MM:SS string.
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds) // Ensure two digits for minutes
    }

    /// Formats duration (seconds) into a user-friendly string (e.g., "X分Y秒" or "Y秒").
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        } else {
            return "\(seconds)秒"
        }
    }

    /// Returns a color based on the exercise difficulty.
    private func difficultyColor(for difficulty: ListeningExercise.Difficulty) -> Color {
        switch difficulty {
        case .beginner: .green
        case .intermediate: .orange
        case .advanced: .red
        }
    }
}

// MARK: - Download Form View (Refactored)
/// A dedicated view for the YouTube download form, presented in a sheet.
struct DownloadFormView: View {
    @Binding var isPresented: Bool
    var onDownload: (String, String) -> Void // Callback with URL and Title

    @State private var downloadURL: String = ""
    @State private var customTitle: String = ""
    @FocusState private var isUrlFieldFocused: Bool // For focusing the field

    var body: some View {
        NavigationView { // Embed in NavigationView for title and potential toolbar items
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("YouTube 视频链接", systemImage: "link")
                    TextField("https://www.youtube.com/watch?v=...", text: $downloadURL)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground)) // Use adaptive color
                        .cornerRadius(10)
                        .focused($isUrlFieldFocused)
                    Text("粘贴完整的 YouTube 视频链接")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("自定义标题（可选）", systemImage: "textformat")
                    TextField("如果留空，将使用视频标题", text: $customTitle)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }

                Spacer() // Push controls to top

                Button {
                    if validateURL() {
                        onDownload(downloadURL, customTitle)
                        isPresented = false // Dismiss sheet
                    } else {
                        // Optionally show an inline error message here
                        print("Invalid URL")
                    }
                } label: {
                    Text("开始导入")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(!validateURL())
                .opacity(validateURL() ? 1.0 : 0.5) // Dim button if URL is invalid

            }
            .padding()
            .navigationTitle("从YouTube导入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { isPresented = false }
                }
            }
            .onAppear {
                 // Focus the URL field when the sheet appears
                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                     isUrlFieldFocused = true
                 }
            }
        }
        // Consider limiting sheet height on larger screens if desired
        // .presentationDetents([.medium])
    }

    /// Basic URL validation.
    private func validateURL() -> Bool {
        // Simple check for youtube.com or youtu.be - enhance as needed
        let trimmedURL = downloadURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedURL.isEmpty &&
               (trimmedURL.contains("youtube.com/watch?v=") || trimmedURL.contains("youtu.be/")) &&
               URL(string: trimmedURL) != nil
    }
}


// MARK: - Transcript View (Minor Refinements)
/// Displays the transcript text within a scrollable view.
struct TranscriptView: View {
    let transcript: String

    var body: some View {
        ScrollView {
            Text(transcript)
                .font(.body)
                .lineSpacing(6)
                .padding() // Padding around the text
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
        }
        // Background color is handled by the sheet's default material
    }
}

// MARK: - Analysis View (Placeholder - Requires implementation)
/// Placeholder view for displaying exercise analysis.
struct AnalysisView: View {
    let analysis: ExerciseAnalysis

    var body: some View {
        // Implement the detailed analysis display here based on the ExerciseAnalysis model
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                 Text("理解分析: \(analysis.comprehensionAnalysis)").padding()
                 Text("难点分析: \(analysis.difficultyAnalysis)").padding()
                 // ... display suggestedTopics, commonMistakes etc.
            }
            .padding()
        }
        .navigationTitle("答案分析") // Example title
    }
}
``
// Add placeholder definition back for AnalysisView to compile
struct ExerciseAnalysis { // Example structure
    var comprehensionAnalysis: String = "Analysis Placeholder"
    var difficultyAnalysis: String = "Difficulty Placeholder"
    var suggestedTopics: [String] = ["Topic 1", "Topic 2"]
    var commonMistakes: [String] = ["Mistake 1", "Mistake 2"]
}

// MARK: - Preview
#Preview {
    // Use NavigationStack for preview consistency
    // Wrap in TabView if it's part of a tabbed interface in reality
     ListeningPracticeView()
         .environmentObject(AuthService.shared) // If needed by sub-dependencies
         .environmentObject(ListeningService.shared) // Provide the mock service
}