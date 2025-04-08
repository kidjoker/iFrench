import Foundation
import AVFoundation
import Combine

/// A service class responsible for managing listening exercises and audio playback functionality.
/// This class handles audio file management, playback control, and exercise state management.
@MainActor
class ListeningService: ObservableObject {
    /// Shared singleton instance of the ListeningService
    static let shared = ListeningService()
    
    // MARK: - Published Properties
    
    /// The list of available listening exercises
    @Published private(set) var exercises: [ListeningExercise] = []
    
    /// The currently selected exercise
    @Published private(set) var currentExercise: ListeningExercise?
    
    /// Indicates whether audio is currently playing
    @Published private(set) var isPlaying = false
    
    /// Current playback progress (0-1)
    @Published private(set) var progress: Double = 0
    
    /// Current playback time in seconds
    @Published private(set) var currentTime: TimeInterval = 0
    
    /// Indicates whether the service is loading data
    @Published private(set) var isLoading = false
    
    /// Current error state, if any
    @Published private(set) var error: Error?
    
    /// Current download progress (0-1)
    @Published private(set) var downloadProgress: Double = 0
    
    // MARK: - Private Properties
    
    private var avPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    /// Directory URL for storing audio files
    private let audioDirectory: URL
    
    /// 问题服务实例，用于生成问题
    private let questionService = QuestionService.shared
    
    // MARK: - Initialization
    
    private init() {
        // 创建音频文件目录
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        audioDirectory = documentsDirectory.appendingPathComponent("AudioFiles", isDirectory: true)
        
        // 确保音频目录存在
        do {
            if !FileManager.default.fileExists(atPath: audioDirectory.path) {
                try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
            }
        } catch {
            print("创建音频目录失败：\(error)")
        }
        
        setupAudioSession()
        #if DEBUG
        loadMockExercises()
        #else
        loadExercises()
        #endif
        
        // 确保示例音频文件已复制到音频目录
        copyBundleAudioFilesToDirectory()
    }
    
    /// 复制Bundle中的音频文件到音频目录
    private func copyBundleAudioFilesToDirectory() {
        let fileManager = FileManager.default
        
        // 尝试多种可能的资源路径
        let possibleResourcePaths = [
            "Resources/Audio",
            "Audio",
            ""
        ]
        
        var foundAudioFiles = false
        
        // 1. 首先尝试直接从Bundle中获取音频文件
        for resourcePath in possibleResourcePaths {
            if let audioFiles = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: resourcePath) {
                print("在路径 '\(resourcePath)' 中找到音频文件：\(audioFiles)")
                
                for bundleURL in audioFiles {
                    let fileName = bundleURL.lastPathComponent
                    let destinationURL = audioDirectory.appendingPathComponent(fileName)
                    
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        print("音频文件已存在：\(fileName)")
                        foundAudioFiles = true
                        continue
                    }
                    
                    do {
                        try fileManager.copyItem(at: bundleURL, to: destinationURL)
                        print("成功复制音频文件到音频目录：\(fileName)")
                        foundAudioFiles = true
                    } catch {
                        print("复制音频文件失败：\(error)")
                    }
                }
                
                if foundAudioFiles {
                    break
                }
            }
        }
        
        // 2. 如果没有找到文件，尝试遍历Bundle中的所有资源
        if !foundAudioFiles {
            print("尝试遍历Bundle中的所有资源")
            if let bundleURL = Bundle.main.resourceURL {
                do {
                    let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .nameKey]
                    let enumerator = fileManager.enumerator(at: bundleURL,
                                                          includingPropertiesForKeys: resourceKeys,
                                                          options: [.skipsHiddenFiles],
                                                          errorHandler: nil)
                    
                    while let fileURL = enumerator?.nextObject() as? URL {
                        guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                              !resourceValues.isDirectory!,
                              fileURL.pathExtension.lowercased() == "mp3" else {
                            continue
                        }
                        
                        let fileName = fileURL.lastPathComponent
                        let destinationURL = audioDirectory.appendingPathComponent(fileName)
                        
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            print("音频文件已存在：\(fileName)")
                            foundAudioFiles = true
                            continue
                        }
                        
                        do {
                            try fileManager.copyItem(at: fileURL, to: destinationURL)
                            print("成功复制音频文件到音频目录：\(fileName)")
                            foundAudioFiles = true
                        } catch {
                            print("复制音频文件失败：\(error)")
                        }
                    }
                }
            }
        }
        
        // 3. 打印最终结果
        do {
            let files = try fileManager.contentsOfDirectory(at: audioDirectory, includingPropertiesForKeys: nil)
            print("音频目录中的文件：")
            for file in files {
                print("- \(file.lastPathComponent)")
            }
            
            if files.isEmpty {
                print("警告：音频目录为空")
            } else {
                print("成功：音频目录包含 \(files.count) 个文件")
            }
        } catch {
            print("无法列出音频目录中的文件：\(error)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads the list of listening exercises.
    /// This method will fetch exercises from the server or local storage.
    /// - Note: Currently implemented with mock data in DEBUG mode
    func loadExercises() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // TODO: Implement actual exercise loading logic
            #if DEBUG
            loadMockExercises()
            #else
            // Future implementation for production
            throw ListeningError.notImplemented
            #endif
        } catch {
            self.error = error
            print("Failed to load exercises: \(error)")
        }
    }
    
    /// 导入音频文件并从元数据中读取相关信息
    /// - Parameter url: 音频文件的源URL
    /// - Throws: 如果文件格式不支持或导入失败，则抛出 `ListeningError`
    func importAudio(from url: URL) async throws {
        isLoading = true
        error = nil
        
        // 使用 defer 而不是 finally 来进行最终清理工作
        defer {
            isLoading = false
        }
        
        print("开始导入音频文件：\(url.lastPathComponent)")
        print("源文件路径：\(url.path)")
        
        do {
            // 记录当前音频目录内容
            let contents = try FileManager.default.contentsOfDirectory(at: audioDirectory, includingPropertiesForKeys: nil)
            print("当前音频目录内容：")
            contents.forEach { print("- \($0.lastPathComponent)") }
            
            // 验证文件格式
            let supportedExtensions = ["mp3", "wav", "m4a", "aac", "mp4", "caf"]
            let fileExtension = url.pathExtension.lowercased()
            print("文件格式：\(fileExtension)")
            
            guard supportedExtensions.contains(fileExtension) else {
                throw ListeningError.unsupportedFormat(fileExtension)
            }
            
            // 生成唯一文件名
            let fileName = UUID().uuidString + "." + fileExtension
            print("将使用文件名：\(fileName)")
            
            // 验证音频文件并读取元数据
            print("正在验证音频文件并读取元数据...")
            let asset = AVURLAsset(url: url)
            let duration = try await asset.load(.duration)
            let audioLength = duration.seconds
            
            // 尝试从元数据中读取所有可用信息
            let metadata = try await asset.load(.metadata)
            var title = url.deletingPathExtension().lastPathComponent
            var artist: String?
            var album: String?
            
            // 从元数据中查找各种信息
            for item in AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierTitle) {
                if let value = try? await item.value as? String {
                    title = value
                }
            }
            
            for item in AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtist) {
                if let value = try? await item.value as? String {
                    artist = value
                }
            }
            
            for item in AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierAlbumName) {
                if let value = try? await item.value as? String {
                    album = value
                }
            }
            
            print("音频时长：\(audioLength) 秒")
            print("音频标题：\(title)")
            if let artist = artist { print("艺术家：\(artist)") }
            if let album = album { print("专辑：\(album)") }
            
            // 保存到音频目录
            print("正在保存音频文件到：\(fileName)")
            let destinationURL = audioDirectory.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // 提取音频转写文本（如果有）
            var transcript = ""
            
            // 利用 QuestionService 生成问题
            print("正在生成相关问题...")
            let questionData = try await questionService.generateQuestions(for: destinationURL, transcript: transcript)
            
            // 如果问题服务返回了转写文本，使用它
            if let generatedTranscript = questionData.transcript {
                transcript = generatedTranscript
            }
            
            // 确定难度级别
            let difficulty: ListeningExercise.Difficulty
            switch questionData.difficulty {
            case "beginner":
                difficulty = .beginner
            case "intermediate":
                difficulty = .intermediate
            case "advanced":
                difficulty = .advanced
            default:
                difficulty = .beginner
            }
            
            // 创建新练习，使用从元数据和问题服务中提取的信息
            let newExercise = ListeningExercise(
                title: title,
                audioFileName: fileName,
                audioLength: audioLength,
                transcript: transcript,
                question: questionData.question,
                options: questionData.options,
                correctOptionIndex: questionData.correctOptionIndex,
                difficulty: difficulty,
                type: .extensive  // 默认类型
            )
            
            exercises.append(newExercise)
            selectExercise(newExercise)
            
            print("成功导入音频，创建练习：\(title)")
        } catch {
            self.error = error
            throw error
        }
    }
    
    /// 选择练习
    func selectExercise(_ exercise: ListeningExercise?) {
        if exercise == nil {
            // 停止当前播放
            pause()
            avPlayer = nil
            progressTimer?.invalidate()
            progressTimer = nil
            progress = 0
            currentTime = 0
        }
        currentExercise = exercise
        if exercise != nil {
            prepareAudio()
        }
    }
    
    /// 播放音频
    func play() {
        guard let player = avPlayer else { return }
        player.play()
        isPlaying = true
        startProgressTimer()
    }
    
    /// 暂停音频
    func pause() {
        avPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    /// 重新开始
    func restart() {
        avPlayer?.currentTime = 0
        currentTime = 0
        progress = 0
        play()
    }
    
    /// 快进
    func forward(_ seconds: TimeInterval = 5) {
        guard let player = avPlayer else { return }
        let newTime = min(player.duration, player.currentTime + seconds)
        player.currentTime = newTime
        updateProgress()
    }
    
    /// 快退
    func backward(_ seconds: TimeInterval = 5) {
        guard let player = avPlayer else { return }
        let newTime = max(0, player.currentTime - seconds)
        player.currentTime = newTime
        updateProgress()
    }
    
    /// 提交答案
    func submitAnswer(_ index: Int) {
        guard var exercise = currentExercise else { return }
        exercise.userSelected = index
        
        // 更新练习状态
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[exerciseIndex] = exercise
        }
        currentExercise = exercise
        
        // 如果答对了，更新学习统计
        if index == exercise.correctOptionIndex {
            updateLearningStats(exercise)
        }
    }
    
    /// 标记时间戳
    func markTimestamp() {
        guard var exercise = currentExercise,
              let player = avPlayer else { return }
        
        let timestamp = player.currentTime
        exercise.markedTimestamps.append(timestamp)
        
        // 更新练习状态
        if let exerciseIndex = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[exerciseIndex] = exercise
        }
        currentExercise = exercise
    }
    
    /// 从URL下载音频
    /// - Parameters:
    ///   - urlString: 音频文件的URL字符串
    ///   - title: 可选的自定义标题
    ///   - isYouTube: 是否为YouTube链接
    /// - Throws: 如果下载失败则抛出错误
    func downloadAudio(from urlString: String, title: String? = nil, isYouTube: Bool = false) async throws {
        isLoading = true
        error = nil
        downloadProgress = 0
        
        // 使用 defer 而不是 finally 来进行最终清理工作
        defer {
            isLoading = false
            downloadProgress = 0
        }
        
        print("开始下载音频，URL: \(urlString)")
        
        // 验证URL
        guard let url = URL(string: urlString) else {
            throw ListeningError.invalidURL
        }
        
        if isYouTube {
            // 处理YouTube链接
            try await processYouTubeURL(url, title: title)
        } else {
            // 处理普通音频链接
            try await downloadRegularAudio(from: url, title: title)
        }
    }
    
    /// 处理YouTube URL
    private func processYouTubeURL(_ url: URL, title: String?) async throws {
        print("处理YouTube链接：\(url)")
        
        // 验证YouTube链接
        guard url.absoluteString.contains("youtube.com") || url.absoluteString.contains("youtu.be") else {
            throw ListeningError.invalidURL
        }
        
        // 提取视频ID
        let videoID: String
        if url.absoluteString.contains("youtu.be") {
            videoID = url.lastPathComponent
        } else if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                  let idItem = queryItems.first(where: { $0.name == "v" }),
                  let id = idItem.value {
            videoID = id
        } else {
            throw ListeningError.invalidURL
        }
        
        print("提取到YouTube视频ID：\(videoID)")
        
        // 设置进度
        downloadProgress = 0.1
        
        // 这里可以使用第三方库或服务来获取YouTube视频的音频URL
        // 为示例简化，我们使用一个模拟函数
        try await downloadYouTubeAudio(from: url, title: title ?? "YouTube Audio")
    }
    
    /// 下载YouTube音频文件
    private func downloadYouTubeAudio(from url: URL, title: String) async throws {
        let fileName = "youtube_\(UUID().uuidString).mp3"
        let destinationURL = audioDirectory.appendingPathComponent(fileName)
        
        // 创建下载会话
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        // 使用 async/await 下载文件
        let (tempFileURL, _) = try await session.download(from: url)
        
        // 如果目标文件已存在，先删除
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // 移动临时文件到目标位置
        try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
        print("文件下载完成：\(destinationURL.path)")
        
        // 确认文件存在
        guard FileManager.default.fileExists(atPath: destinationURL.path) else {
            throw ListeningError.importError(NSError(domain: "ListeningService", 
                                                   code: -5,
                                                   userInfo: [NSLocalizedDescriptionKey: "文件移动后不存在"]))
        }
        
        // 读取音频文件元数据
        let asset = AVURLAsset(url: destinationURL)
        let duration = try await asset.load(.duration)
        let audioLength = duration.seconds
        
        // 尝试从元数据中读取所有可用信息
        let metadata = try await asset.load(.metadata)
        var artist: String?
        var album: String?
        
        // 从元数据中查找各种信息
        for item in AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtist) {
            if let value = try? await item.value as? String {
                artist = value
            }
        }
        
        for item in AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierAlbumName) {
            if let value = try? await item.value as? String {
                album = value
            }
        }
        
        print("音频时长：\(audioLength) 秒")
        print("音频标题：\(title)")
        if let artist = artist { print("艺术家：\(artist)") }
        if let album = album { print("专辑：\(album)") }
        
        // 使用 QuestionService 生成问题
        print("正在生成相关问题...")
        let questionData = try await questionService.generateQuestions(for: destinationURL)
        
        // 确定难度级别
        let difficulty: ListeningExercise.Difficulty
        switch questionData.difficulty {
        case "beginner":
            difficulty = .beginner
        case "intermediate":
            difficulty = .intermediate
        case "advanced":
            difficulty = .advanced
        default:
            difficulty = .beginner
        }
        
        // 创建新练习，使用从元数据和问题服务中提取的信息
        let newExercise = ListeningExercise(
            title: title,
            audioFileName: fileName,
            audioLength: audioLength,
            transcript: questionData.transcript ?? "",  // 使用问题服务生成的转写
            question: questionData.question,
            options: questionData.options,
            correctOptionIndex: questionData.correctOptionIndex,
            difficulty: difficulty,
            type: .extensive  // 默认类型
        )
        
        exercises.append(newExercise)
        selectExercise(newExercise)
    }
    
    /// 下载普通音频文件
    private func downloadRegularAudio(from url: URL, title: String?) async throws {
        // 创建下载会话
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        // 设置进度监听
        downloadProgress = 0.1
        
        // 使用 async/await 下载文件
        let (tempFileURL, response) = try await session.download(from: url, delegate: nil)
        
        // 检查响应
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ListeningError.networkError
        }
        
        // 提取文件名
        let fileName: String
        if let suggestedFilename = httpResponse.suggestedFilename {
            fileName = suggestedFilename
        } else {
            fileName = "download_\(UUID().uuidString).\(url.pathExtension)"
        }
        
        // 保存文件
        let destinationURL = audioDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
        print("文件下载完成：\(destinationURL.path)")
        
        // 读取音频元数据
        let asset = AVURLAsset(url: destinationURL)
        let duration = try await asset.load(.duration)
        let audioLength = duration.seconds
        
        // 设置标题
        let audioTitle = title ?? url.deletingPathExtension().lastPathComponent
        
        // 使用 QuestionService 生成问题
        print("正在生成相关问题...")
        let questionData = try await questionService.generateQuestions(for: destinationURL)
        
        // 确定难度级别
        let difficulty: ListeningExercise.Difficulty
        switch questionData.difficulty {
        case "beginner":
            difficulty = .beginner
        case "intermediate":
            difficulty = .intermediate
        case "advanced":
            difficulty = .advanced
        default:
            difficulty = .beginner
        }
        
        // 创建新练习
        let newExercise = ListeningExercise(
            title: audioTitle,
            audioFileName: fileName,
            audioLength: audioLength,
            transcript: questionData.transcript ?? "",
            question: questionData.question,
            options: questionData.options,
            correctOptionIndex: questionData.correctOptionIndex,
            difficulty: difficulty,
            type: .extensive
        )
        
        exercises.append(newExercise)
        selectExercise(newExercise)
    }
    
    /// 设置播放位置
    func seekToPosition(_ progress: Double) {
        guard let player = avPlayer,
              let duration = currentExercise?.audioLength else { return }
        
        let newTime = duration * progress
        player.currentTime = newTime
        currentTime = newTime
        self.progress = progress
        updateProgress()
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadMockExercises() {
        exercises = MockData.listeningExercises
    }
    
    private func prepareAudio() {
        guard let exercise = currentExercise else { return }
        print("准备加载音频：\(exercise.audioFileName)")
        
        // 处理相对路径
        let audioFileName = exercise.audioFileName.components(separatedBy: "/").last ?? exercise.audioFileName
        print("处理后的文件名：\(audioFileName)")
        
        // 首先尝试从Bundle的Resources/Audio目录加载
        if let bundleAudioURL = Bundle.main.url(forResource: "Resources/Audio/\(audioFileName.replacingOccurrences(of: ".mp3", with: ""))", 
                                              withExtension: "mp3") {
            print("在Bundle中找到文件")
            do {
                avPlayer = try AVAudioPlayer(contentsOf: bundleAudioURL)
                avPlayer?.prepareToPlay()
                progress = 0
                currentTime = 0
                print("成功从Bundle加载音频文件")
                return
            } catch {
                print("从Bundle加载失败：\(error)")
            }
        }
        
        // 如果Bundle中没有，尝试从音频目录加载
        let audioURL = audioDirectory.appendingPathComponent(audioFileName)
        print("尝试从音频目录加载：\(audioURL.path)")
        
        if FileManager.default.fileExists(atPath: audioURL.path) {
            print("在音频目录中找到文件")
            do {
                avPlayer = try AVAudioPlayer(contentsOf: audioURL)
                avPlayer?.prepareToPlay()
                progress = 0
                currentTime = 0
                print("成功加载音频文件")
                return
            } catch {
                self.error = ListeningError.playbackError(error)
                print("从音频目录加载失败：\(error)")
            }
        }
        
        print("音频文件未找到：\(exercise.audioFileName)")
        print("已检查的位置：")
        print("1. Bundle：Resources/Audio/\(audioFileName)")
        print("2. 音频目录：\(audioURL.path)")
        self.error = ListeningError.audioNotFound
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateProgress() {
        guard let player = avPlayer else { return }
        progress = player.currentTime / player.duration
        currentTime = player.currentTime
        
        if player.currentTime >= player.duration {
            pause()
        }
    }
    
    private func updateLearningStats(_ exercise: ListeningExercise) {
        let stats = LearningStats(
            duration: exercise.audioLength,
            topic: .listening,
            completedItems: 1,
            accuracy: exercise.userSelected == exercise.correctOptionIndex ? 1.0 : 0.0
        )
        StatsService.shared.addLearningStats(stats)
    }
    
    /// 为指定练习重新生成问题
    /// - Parameter exercise: 需要重新生成问题的练习
    /// - Returns: 更新后的练习
    @MainActor func regenerateQuestions(for exercise: ListeningExercise) async throws -> ListeningExercise {
        isLoading = true
        defer { isLoading = false }
        
        // 获取练习的问题
        do {
            let newQuestions = try await QuestionService.shared.generateQuestions(for: exercise)
            
            // 创建更新后的练习
            var updatedExercise = exercise
            updatedExercise.questions = newQuestions
            
            // 更新练习列表
            if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
                exercises[index] = updatedExercise
            }
            
            // 如果当前选中的是这个练习，也更新当前练习
            if currentExercise?.id == exercise.id {
                currentExercise = updatedExercise
            }
            
            return updatedExercise
        } catch {
            self.error = error
            throw error
        }
    }
}

// MARK: - Error Types
extension ListeningService {
    enum ListeningError: LocalizedError {
        case audioNotFound
        case playbackError(Error)
        case invalidExercise
        case importError(Error)
        case youtubeExtractionFailed(String)
        case youtubeInvalidURL
        case youtubeUnsupported
        case invalidURL
        case downloadError(Error)
        case notImplemented
        case unsupportedFormat(String)
        case networkError
        case exerciseNotFound
        
        var errorDescription: String? {
            switch self {
            case .audioNotFound:
                return "找不到音频文件"
            case .playbackError(let error):
                return "播放错误：\(error.localizedDescription)"
            case .invalidExercise:
                return "无效的练习"
            case .importError(let error):
                return "导入错误：\(error.localizedDescription)"
            case .youtubeExtractionFailed(let reason):
                return "YouTube音频提取失败：\(reason)"
            case .youtubeInvalidURL:
                return "无效的YouTube链接"
            case .youtubeUnsupported:
                return "不支持的YouTube视频类型"
            case .invalidURL:
                return "无效的URL"
            case .downloadError(let error):
                return "下载错误：\(error.localizedDescription)"
            case .notImplemented:
                return "功能未实现"
            case .unsupportedFormat(let format):
                return "不支持的音频格式：\(format)"
            case .networkError:
                return "网络错误"
            case .exerciseNotFound:
                return "练习未找到"
            }
        }
    }
} 