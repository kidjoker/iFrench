import Foundation
import Combine

/// DeepSeek服务类，负责处理AI相关功能
class DeepSeekService: ObservableObject {
    /// 单例实例
    static let shared = DeepSeekService()
    
    // MARK: - Published Properties
    
    /// 处理状态
    @Published private(set) var isProcessing = false
    
    /// 错误信息
    @Published private(set) var error: Error?
    
    /// 语音识别结果
    @Published private(set) var transcriptionResult: String?
    
    /// 发音评分（0-100）
    @Published private(set) var pronunciationScore: Int?
    
    /// 理解分析结果
    @Published private(set) var comprehensionAnalysis: ComprehensionAnalysis?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    /// DeepSeek API 基础URL
    private let apiBaseURL = "https://api.deepseek.com/v1"
    
    /// DeepSeek API 密钥，从配置读取
    private let apiKey: String
    
    /// 用于HTTP请求的会话
    private let session: URLSession
    
    // MARK: - Initialization
    
    private init() {
        // 通过Configuration获取API Key
        self.apiKey = Configuration.deepseekApiKey
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    /// 生成文本
    /// - Parameters:
    ///   - prompt: 提示文本
    ///   - model: 使用的模型
    /// - Returns: 生成的文本
    func generateText(prompt: String, model: DeepSeekModel = .deepseekText) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        // 检查 API key 是否可用
        guard !apiKey.isEmpty else {
            throw DeepSeekError.apiError("DeepSeek API Key 未配置")
        }
        
        let endpoint = "\(apiBaseURL)/\(model.rawValue)/completions"
        
        guard let url = URL(string: endpoint) else {
            throw DeepSeekError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "max_tokens": 1000,
            "temperature": 0.7,
            "top_p": 0.9
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw DeepSeekError.apiError("服务器返回非200状态码")
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let text = firstChoice["text"] as? String {
                return text
            } else {
                throw DeepSeekError.invalidResponse
            }
        } catch let error as DeepSeekError {
            throw error
        } catch {
            // 如果API调用失败，使用本地生成
            return try await localTextGeneration(prompt: prompt)
        }
    }
    
    /// 分析用户发音
    /// - Parameters:
    ///   - audioData: 用户录音数据
    ///   - transcript: 标准文本
    func analyzePronunciation(_ audioData: Data, transcript: String) async throws -> PronunciationResult {
        isProcessing = true
        defer { isProcessing = false }
        
        // TODO: 调用 DeepSeek API 进行语音识别和评分
        // 这里使用模拟数据
        return PronunciationResult(
            transcript: transcript,
            userTranscript: "Je m'appelle Marie",
            score: 85,
            details: [
                .init(word: "Je", score: 90),
                .init(word: "m'appelle", score: 80),
                .init(word: "Marie", score: 85)
            ]
        )
    }
    
    /// 分析听力理解
    /// - Parameters:
    ///   - exercise: 听力练习
    ///   - userAnswer: 用户答案
    func analyzeComprehension(_ exercise: ListeningExercise, userAnswer: Int) async throws -> ComprehensionAnalysis {
        isProcessing = true
        defer { isProcessing = false }
        
        // 构建提示
        let prompt = """
        我正在进行一个法语听力练习。原文如下：
        
        "\(exercise.transcript)"
        
        题目是："\(exercise.question)"
        
        选项有：
        \(exercise.options.enumerated().map { index, option in "\(index). \(option)" }.joined(separator: "\n"))
        
        正确答案是：\(exercise.correctOptionIndex)
        我选择的答案是：\(userAnswer)
        
        请分析我的选择，提供解释，推荐学习主题，难度分析和常见错误。
        """
        
        do {
            let analysisText = try await generateText(prompt: prompt)
            return parseComprehensionAnalysis(analysisText, exercise: exercise, userAnswer: userAnswer)
        } catch {
            // 如果API调用失败，使用本地生成的分析
            return ComprehensionAnalysis(
                isCorrect: userAnswer == exercise.correctOptionIndex,
                explanation: "这道题考察基本问候用语的理解。在对话中，'Je m'appelle' 是法语中表示'我叫...'的常用表达。",
                suggestedTopics: ["基础问候", "自我介绍"],
                difficultyAnalysis: "这是一个初级难度的练习，主要考察最基本的问候和自我介绍表达。",
                commonMistakes: [
                    "混淆 'Je m'appelle' 和 'Comment allez-vous'",
                    "未能识别基本问候语 'Bonjour'"
                ]
            )
        }
    }
    
    /// 获取个性化练习推荐
    /// - Parameter userStats: 用户学习统计
    func getPersonalizedRecommendations(userStats: LearningStats) async throws -> [ExerciseRecommendation] {
        isProcessing = true
        defer { isProcessing = false }
        
        // 构建提示
        let prompt = """
        我正在学习法语，以下是我的学习统计数据：
        
        学习时长：\(userStats.duration) 秒
        学习主题：\(userStats.topic.rawValue)
        完成项目数：\(userStats.completedItems)
        准确率：\(userStats.accuracy * 100)%
        
        请根据我的学习情况，推荐2-3个适合我的听力练习类型和难度。
        """
        
        do {
            let recommendationsText = try await generateText(prompt: prompt)
            return parseRecommendations(recommendationsText)
        } catch {
            // 如果API调用失败，使用本地生成的推荐
            return [
                ExerciseRecommendation(
                    type: .precision,
                    difficulty: .beginner,
                    reason: "根据您的学习记录，建议继续加强基础对话的精听训练。",
                    confidence: 0.85
                ),
                ExerciseRecommendation(
                    type: .extensive,
                    difficulty: .intermediate,
                    reason: "您在基础对话方面表现良好，可以尝试一些中级难度的泛听练习。",
                    confidence: 0.75
                )
            ]
        }
    }
    
    // MARK: - Private Methods
    
    /// 本地文本生成（当API调用失败时）
    private func localTextGeneration(prompt: String) async throws -> String {
        // 根据提示内容返回不同的预设响应
        
        if prompt.contains("听力理解测试问题") {
            // 返回问题生成模板
            return """
            问题: 根据音频内容，下列哪种说法最准确？
            选项:
            0. 这是一段介绍法国文化的对话
            1. 两个人正在讨论天气情况
            2. 一个人在询问方向
            3. 这是一段日常购物的对话
            正确答案: 3
            难度: intermediate
            """
        } else if prompt.contains("分析我的选择") {
            // 返回理解分析模板
            return """
            解释:
            这道题目考察对日常对话的理解能力。正确答案是选项3，因为对话中包含了商品价格、支付方式等购物场景常见表达。

            建议学习主题:
            - 购物相关词汇
            - 数字和价格表达
            - 商店对话场景

            难度分析:
            这是一个中级难度的练习，需要理解特定情境下的常用表达和专业词汇。

            常见错误:
            - 混淆价格表达方式
            - 未能识别商品描述词汇
            - 忽略对话中的语境线索
            """
        } else if prompt.contains("推荐2-3个适合我的听力练习") {
            // 返回个性化推荐模板
            return """
            推荐练习:
            1. 精听练习 - 初级难度：适合巩固基础词汇和语法，提高听音辨别能力。
            2. 泛听练习 - 中级难度：帮助您提高对自然语速法语的理解能力。
            3. 听说跟读 - 初级难度：改善发音和语调，提高口语流利度。
            """
        } else {
            // 默认响应
            return "很抱歉，我无法理解您的请求。请提供更具体的指示。"
        }
    }
    
    /// 解析理解分析结果
    private func parseComprehensionAnalysis(_ text: String, exercise: ListeningExercise, userAnswer: Int) -> ComprehensionAnalysis {
        // 解析说明
        var explanation = ""
        if let explanationRange = text.range(of: "解释:.*?(建议学习主题|难度分析|常见错误)", options: [.regularExpression]) {
            let explanationText = String(text[explanationRange.lowerBound..<explanationRange.upperBound])
            explanation = explanationText.replacingOccurrences(of: "解释:", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        // 解析建议学习主题
        var suggestedTopics: [String] = []
        if let topicsRange = text.range(of: "建议学习主题:.*?(难度分析|常见错误)", options: [.regularExpression]) {
            let topicsText = String(text[topicsRange.lowerBound..<topicsRange.upperBound])
            let topicLines = topicsText.split(separator: "\n").filter { $0.contains("-") }
            
            for line in topicLines {
                if let dashIndex = line.firstIndex(of: "-"), dashIndex < line.endIndex {
                    let topic = String(line[line.index(after: dashIndex)...]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if !topic.isEmpty {
                        suggestedTopics.append(topic)
                    }
                }
            }
        }
        
        // 解析难度分析
        var difficultyAnalysis = ""
        if let difficultyRange = text.range(of: "难度分析:.*?(常见错误|$)", options: [.regularExpression]) {
            let difficultyText = String(text[difficultyRange.lowerBound..<difficultyRange.upperBound])
            difficultyAnalysis = difficultyText.replacingOccurrences(of: "难度分析:", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        // 解析常见错误
        var commonMistakes: [String] = []
        if let mistakesRange = text.range(of: "常见错误:.*?($)", options: [.regularExpression]) {
            let mistakesText = String(text[mistakesRange.lowerBound..<mistakesRange.upperBound])
            let mistakeLines = mistakesText.split(separator: "\n").filter { $0.contains("-") }
            
            for line in mistakeLines {
                if let dashIndex = line.firstIndex(of: "-"), dashIndex < line.endIndex {
                    let mistake = String(line[line.index(after: dashIndex)...]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if !mistake.isEmpty {
                        commonMistakes.append(mistake)
                    }
                }
            }
        }
        
        return ComprehensionAnalysis(
            isCorrect: userAnswer == exercise.correctOptionIndex,
            explanation: explanation,
            suggestedTopics: suggestedTopics,
            difficultyAnalysis: difficultyAnalysis,
            commonMistakes: commonMistakes
        )
    }
    
    /// 解析个性化推荐
    private func parseRecommendations(_ text: String) -> [ExerciseRecommendation] {
        var recommendations: [ExerciseRecommendation] = []
        
        // 拆分推荐行
        let recommendationLines = text.split(separator: "\n").filter { $0.contains(".") }
        
        for line in recommendationLines {
            // 尝试匹配练习类型
            var exerciseType: ListeningExercise.ExerciseType = .extensive
            if line.contains("精听") {
                exerciseType = .precision
            } else if line.contains("泛听") {
                exerciseType = .extensive
            } else if line.contains("听说") || line.contains("跟读") {
                exerciseType = .listenRepeat
            }
            
            // 尝试匹配难度
            var difficulty: ListeningExercise.Difficulty = .beginner
            if line.contains("高级") || line.contains("advanced") {
                difficulty = .advanced
            } else if line.contains("中级") || line.contains("intermediate") {
                difficulty = .intermediate
            } else if line.contains("初级") || line.contains("beginner") {
                difficulty = .beginner
            }
            
            // 提取原因
            let reason = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 创建推荐
            let recommendation = ExerciseRecommendation(
                type: exerciseType,
                difficulty: difficulty,
                reason: reason,
                confidence: 0.85 // 默认值
            )
            
            recommendations.append(recommendation)
        }
        
        return recommendations.isEmpty ? 
            [ExerciseRecommendation(type: .extensive, difficulty: .beginner, reason: "建议从基础泛听开始", confidence: 0.9)] : 
            recommendations
    }
}

// MARK: - Models

extension DeepSeekService {
    enum DeepSeekModel: String {
        case deepseekText = "text-generation"
        case deepseekChat = "chat-completion"
        case deepseekAudio = "audio-transcription"
    }
    
    struct PronunciationResult {
        let transcript: String
        let userTranscript: String
        let score: Int
        let details: [WordScore]
        
        struct WordScore {
            let word: String
            let score: Int
        }
    }
    
    struct ComprehensionAnalysis {
        let isCorrect: Bool
        let explanation: String
        let suggestedTopics: [String]
        let difficultyAnalysis: String
        let commonMistakes: [String]
    }
    
    struct ExerciseRecommendation {
        let type: ListeningExercise.ExerciseType
        let difficulty: ListeningExercise.Difficulty
        let reason: String
        let confidence: Double
    }
    
    enum DeepSeekError: Error, LocalizedError {
        case apiError(String)
        case invalidResponse
        case processingError
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .apiError(let message):
                return "API错误: \(message)"
            case .invalidResponse:
                return "无效的响应"
            case .processingError:
                return "处理错误"
            case .invalidURL:
                return "无效的URL"
            }
        }
    }
} 