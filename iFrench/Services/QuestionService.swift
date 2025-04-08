import Foundation
import AVFoundation
import Combine
import Speech

/// 问题生成服务
@MainActor class QuestionService: ObservableObject {
    /// 单例实例
    static let shared = QuestionService()
    
    // MARK: - Published Properties
    
    /// 处理状态
    @Published private(set) var isProcessing = false
    
    /// 错误信息
    @Published private(set) var error: Error?
    
    /// 音频转录结果
    @Published private(set) var transcriptionResult: String?
    
    // MARK: - Private Properties
    
    /// Google Cloud API Key，从Configuration读取
    private let googleCloudAPIKey: String
    
    /// Google Cloud Storage API 基础URL
    private let storageAPIBaseURL = "https://storage.googleapis.com/storage/v1"
    
    /// Google Cloud Speech API 基础URL
    private let speechAPIBaseURL = "https://speech.googleapis.com/v1p1beta1/speech:longrunningrecognize"
    
    /// Google Cloud Storage 存储桶名称
    private let bucketName = "ifrench"
    
    /// OAuth access token
    private var accessToken: String?
    private var tokenExpirationDate: Date?
    
    // MARK: - Initialization
    
    private init() {
        // 通过Configuration获取API Key
        self.googleCloudAPIKey = Configuration.googleCloudApiKey
    }
    
    // MARK: - Public Methods
    
    /// 为听力练习生成问题
    /// - Parameters:
    ///   - exercise: 听力练习
    ///   - transcript: 可选的现有文本转录
    /// - Returns: 生成的问题集
    func generateQuestions(for exercise: ListeningExercise, transcript: String? = nil) async throws -> [ListeningQuestion] {
        isProcessing = true
        defer { isProcessing = false }
        
        // 如果有提供转录，则直接使用
        var audioTranscript = transcript
        
        // 如果没有转录，尝试获取
        if audioTranscript == nil {
            do {
                guard let audioURL = exercise.audioURL else {
                    throw QuestionServiceError.audioFileNotFound
                }
                
                audioTranscript = try await transcribeAudio(audioURL)
                print("转录成功: \(audioTranscript ?? "")")
            } catch {
                print("转录失败: \(error.localizedDescription)")
                // 如果转录失败，仍然尝试基于元数据生成问题
                audioTranscript = exercise.transcript
            }
        }
        
        // 使用转录生成问题
        if let transcriptText = audioTranscript, !transcriptText.isEmpty {
            do {
                return try await generateQuestionsFromText(transcriptText)
            } catch {
                print("从文本生成问题失败: \(error.localizedDescription)")
                // 如果生成失败，使用基本问题
            }
        }
        
        // 退回到基本问题生成
        return generateBasicQuestions(for: exercise)
    }
    
    /// 从URL生成问题（兼容以前的API）
    /// - Parameters:
    ///   - audioURL: 音频文件URL
    ///   - transcript: 可选的现有文本转录
    /// - Returns: 生成的问题数据
    func generateQuestions(for audioURL: URL, transcript: String? = nil) async throws -> QuestionData {
        isProcessing = true
        defer { isProcessing = false }
        
        // 转录音频
        let audioTranscript: String
        if let providedTranscript = transcript {
            audioTranscript = providedTranscript
        } else {
            audioTranscript = try await transcribeAudio(audioURL)
        }
        
        // 读取音频元数据
        let asset = AVURLAsset(url: audioURL)
        let duration = try await asset.load(.duration)
        let audioLength = duration.seconds
        
        // 生成问题
        let questions = try await generateQuestionsFromText(audioTranscript)
        
        // 从生成的问题中选择第一个作为主要问题
        if let firstQuestion = questions.first {
            return QuestionData(
                question: firstQuestion.question,
                options: firstQuestion.options,
                correctOptionIndex: firstQuestion.correctOptionIndex,
                transcript: audioTranscript,
                difficulty: difficultyToString(firstQuestion.difficulty),
                tags: ["auto-generated"]
            )
        }
        
        // 如果没有生成问题，返回基本问题
        return QuestionData(
            question: "根据音频内容，请选择最合适的描述：",
            options: [
                "这是一段法语对话",
                "这是一段法语讲解",
                "这是一段法语演讲",
                "这是一段法语朗读"
            ],
            correctOptionIndex: 0,
            transcript: audioTranscript,
            difficulty: "beginner",
            tags: ["basic-question"]
        )
    }
    
    // MARK: - Private Methods
    
    /// 获取OAuth access token
    private func getAccessToken() async throws -> String {
        // 如果token还有效，直接返回
        if let token = accessToken,
           let expirationDate = tokenExpirationDate,
           expirationDate > Date() {
            return token
        }
        
        // 从配置中获取服务账号凭证
        guard let credentialsPath = Bundle.main.path(forResource: "service-account", ofType: "json") else {
            throw QuestionServiceError.apiError("找不到服务账号凭证文件")
        }
        
        let credentialsData = try Data(contentsOf: URL(fileURLWithPath: credentialsPath))
        guard let credentials = try JSONSerialization.jsonObject(with: credentialsData) as? [String: Any],
              let clientEmail = credentials["client_email"] as? String,
              let privateKey = credentials["private_key"] as? String else {
            throw QuestionServiceError.apiError("无效的服务账号凭证")
        }
        
        // 创建JWT
        let header = [
            "alg": "RS256",
            "typ": "JWT"
        ]
        
        let now = Date()
        let exp = now.addingTimeInterval(3600) // 1小时后过期
        
        let claims = [
            "iss": clientEmail,
            "scope": "https://www.googleapis.com/auth/cloud-platform",
            "aud": "https://oauth2.googleapis.com/token",
            "exp": Int(exp.timeIntervalSince1970),
            "iat": Int(now.timeIntervalSince1970)
        ] as [String : Any]
        
        // 编码JWT
        let headerData = try JSONSerialization.data(withJSONObject: header)
        let claimsData = try JSONSerialization.data(withJSONObject: claims)
        
        let headerBase64 = headerData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let claimsBase64 = claimsData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let signInput = "\(headerBase64).\(claimsBase64)"
        
        // 使用私钥签名
        let cleanPrivateKey = privateKey
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let keyData = Data(base64Encoded: cleanPrivateKey) else {
            print("Debug - Private key processing failed. Key length: \(cleanPrivateKey.count)")
            throw QuestionServiceError.apiError("无效的私钥格式")
        }
        
        var error: Unmanaged<CFError>?
        guard let privateKeyRef = SecKeyCreateWithData(keyData as CFData,
                                                     [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                                      kSecAttrKeyClass: kSecAttrKeyClassPrivate] as CFDictionary,
                                                     &error) else {
            throw QuestionServiceError.apiError("创建私钥引用失败")
        }
        
        guard let signData = signInput.data(using: .utf8) else {
            throw QuestionServiceError.apiError("签名数据编码失败")
        }
        
        guard let signature = SecKeyCreateSignature(privateKeyRef,
                                                  .rsaSignatureMessagePKCS1v15SHA256,
                                                  signData as CFData,
                                                  &error) as Data? else {
            throw QuestionServiceError.apiError("JWT签名失败")
        }
        
        let signatureBase64 = signature.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        
        let jwt = "\(signInput).\(signatureBase64)"
        
        // 获取access token
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw QuestionServiceError.apiError("获取access token失败")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String,
              let expiresIn = json["expires_in"] as? TimeInterval else {
            throw QuestionServiceError.apiError("无效的token响应")
        }
        
        self.accessToken = accessToken
        self.tokenExpirationDate = Date().addingTimeInterval(expiresIn)
        
        return accessToken
    }
    
    /// 上传音频文件到Google Cloud Storage
    /// - Parameter audioURL: 本地音频文件URL
    /// - Returns: GCS中的文件URL
    private func uploadAudioToGCS(_ audioURL: URL) async throws -> String {
        // 获取access token
        let accessToken = try await getAccessToken()
        
        // 生成唯一的文件名
        let fileName = "\(UUID().uuidString).mp3"
        
        // 创建上传URL
        var urlComponents = URLComponents(string: "\(storageAPIBaseURL)/b/\(bucketName)/o")
        urlComponents?.queryItems = [
            URLQueryItem(name: "uploadType", value: "media"),
            URLQueryItem(name: "name", value: fileName)
        ]
        
        guard let uploadURL = urlComponents?.url else {
            throw QuestionServiceError.invalidURL
        }
        
        // 读取音频文件数据
        let audioData = try Data(contentsOf: audioURL)
        
        // 创建上传请求
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("audio/mpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = audioData
        
        // 发送上传请求
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw QuestionServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let responseString = String(data: data, encoding: .utf8) {
                throw QuestionServiceError.apiError("上传文件失败: \(responseString)")
            }
            throw QuestionServiceError.apiError("上传文件失败: HTTP \(httpResponse.statusCode)")
        }
        
        // 返回GCS文件URL
        return "gs://\(bucketName)/\(fileName)"
    }
    
    /// 转录音频文件
    /// - Parameter audioURL: 音频文件URL
    /// - Returns: 转录文本
    private func transcribeAudio(_ audioURL: URL) async throws -> String {
        // 检查 API key 是否可用
        guard !googleCloudAPIKey.isEmpty else {
            throw QuestionServiceError.apiError("Google Cloud API Key 未配置")
        }
        
        // 先将音频上传到GCS
        let gcsURI = try await uploadAudioToGCS(audioURL)
        
        // 创建请求体
        let requestBody: [String: Any] = [
            "config": [
                "encoding": "MP3",
                "sampleRateHertz": 44100,
                "languageCode": "fr-FR",
                "enableAutomaticPunctuation": true,
                "model": "default",
                "audioChannelCount": 2,
                "enableSeparateRecognitionPerChannel": false
            ],
            "audio": [
                "uri": gcsURI
            ]
        ]
        
        // 创建URL请求
        var urlComponents = URLComponents(string: speechAPIBaseURL)
        urlComponents?.queryItems = [URLQueryItem(name: "key", value: googleCloudAPIKey)]
        
        guard let url = urlComponents?.url else {
            throw QuestionServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // 发送请求并获取操作名称
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw QuestionServiceError.invalidResponse
        }
        
        // 打印响应状态码和数据，用于调试
        print("Google Cloud API Response Status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Google Cloud API Response: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let responseString = String(data: data, encoding: .utf8) {
                throw QuestionServiceError.apiError("Google Cloud Speech API错误: \(responseString)")
            } else {
                throw QuestionServiceError.apiError("Google Cloud Speech API返回状态码: \(httpResponse.statusCode)")
            }
        }
        
        // 解析操作名称
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let operationName = json["name"] as? String else {
            throw QuestionServiceError.invalidResponse
        }
        
        // 轮询操作状态直到完成
        let operationURL = "https://speech.googleapis.com/v1p1beta1/operations/\(operationName)"
        var isCompleted = false
        var transcriptionResult: String?
        var retryCount = 0
        let maxRetries = 30 // 最多等待60秒
        
        while !isCompleted && retryCount < maxRetries {
            retryCount += 1
            
            // 等待一段时间再检查状态
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2秒
            
            var operationComponents = URLComponents(string: operationURL)
            operationComponents?.queryItems = [URLQueryItem(name: "key", value: googleCloudAPIKey)]
            
            guard let checkURL = operationComponents?.url else {
                throw QuestionServiceError.invalidURL
            }
            
            let (checkData, checkResponse) = try await URLSession.shared.data(for: URLRequest(url: checkURL))
            
            guard let checkHttpResponse = checkResponse as? HTTPURLResponse,
                  (200...299).contains(checkHttpResponse.statusCode) else {
                throw QuestionServiceError.apiError("检查操作状态失败")
            }
            
            if let checkJson = try JSONSerialization.jsonObject(with: checkData) as? [String: Any] {
                // 检查是否完成
                if let done = checkJson["done"] as? Bool, done {
                    isCompleted = true
                    
                    // 解析结果
                    if let response = checkJson["response"] as? [String: Any],
                       let results = response["results"] as? [[String: Any]],
                       let firstResult = results.first,
                       let alternatives = firstResult["alternatives"] as? [[String: Any]],
                       let firstAlternative = alternatives.first,
                       let transcript = firstAlternative["transcript"] as? String {
                        transcriptionResult = transcript
                    }
                }
            }
        }
        
        guard let finalTranscript = transcriptionResult else {
            throw QuestionServiceError.transcriptionFailed
        }
        
        return finalTranscript
    }
    
    /// 从文本生成问题
    /// - Parameter text: 音频转录文本
    /// - Returns: 生成的问题集
    private func generateQuestionsFromText(_ text: String) async throws -> [ListeningQuestion] {
        // 使用DeepSeek生成问题
        do {
            let prompt = """
            请根据以下法语文本生成3个听力理解测试问题。每个问题应包含问题本身，4个选项（标记为0-3），正确答案索引，和难度级别（beginner, intermediate, advanced）。
            
            文本内容:
            \(text)
            
            输出格式示例:
            问题1: 根据对话内容，两个人在哪里见面？
            选项1:
            0. 咖啡馆
            1. 商场
            2. 学校
            3. 公园
            正确答案1: 0
            难度1: beginner
            
            问题2: ...
            """
            
            let response = try await DeepSeekService.shared.generateText(prompt: prompt)
            return parseQuestionsFromDeepSeekResponse(response)
        } catch {
            print("DeepSeek生成问题失败: \(error.localizedDescription)")
            throw QuestionServiceError.questionGenerationFailed
        }
    }
    
    /// 从DeepSeek响应解析问题
    /// - Parameter response: DeepSeek响应文本
    /// - Returns: 解析后的问题数组
    private func parseQuestionsFromDeepSeekResponse(_ response: String) -> [ListeningQuestion] {
        var questions: [ListeningQuestion] = []
        
        // 按问题分割响应
        let questionBlocks = response.components(separatedBy: "\n\n")
            .filter { $0.contains("问题") && $0.contains("选项") && $0.contains("正确答案") }
        
        for block in questionBlocks {
            // 解析问题文本
            var questionText = ""
            if let questionLine = block.components(separatedBy: "\n").first(where: { $0.contains("问题") }) {
                if let colonIndex = questionLine.firstIndex(of: ":") {
                    questionText = String(questionLine[questionLine.index(after: colonIndex)...]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                }
            }
            
            // 解析选项
            var options: [String] = []
            let optionLines = block.components(separatedBy: "\n")
                .filter { line in
                    // 查找如 "0. 选项内容" 或 "选项: 0. 选项内容" 格式的行
                    if let firstChar = line.first, firstChar.isNumber {
                        return line.contains(".")
                    }
                    return line.contains("选项") && line.contains(".")
                }
            
            for line in optionLines {
                if let dotIndex = line.firstIndex(of: "."),
                   dotIndex < line.endIndex,
                   dotIndex.utf16Offset(in: line) + 1 < line.count {
                    let option = String(line[line.index(dotIndex, offsetBy: 1)...]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    options.append(option)
                }
            }
            
            // 解析正确答案
            var correctOptionIndex = 0
            if let answerLine = block.components(separatedBy: "\n").first(where: { $0.contains("正确答案") }),
               let answerText = answerLine.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
               let answerIndex = Int(answerText) {
                correctOptionIndex = answerIndex
            }
            
            // 解析难度
            var difficulty = ListeningExercise.Difficulty.intermediate
            if let difficultyLine = block.components(separatedBy: "\n").first(where: { $0.contains("难度") }),
               let difficultyText = difficultyLine.components(separatedBy: ":").last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                if difficultyText.contains("beginner") {
                    difficulty = .beginner
                } else if difficultyText.contains("advanced") {
                    difficulty = .advanced
                }
            }
            
            // 创建问题对象
            if !questionText.isEmpty && options.count >= 2 {
                let question = ListeningQuestion(
                    id: UUID().uuidString,
                    question: questionText,
                    options: options,
                    correctOptionIndex: correctOptionIndex,
                    difficulty: difficulty
                )
                questions.append(question)
            }
        }
        
        return questions.isEmpty ? generateFallbackQuestions() : questions
    }
    
    /// 生成基本问题（基于音频文件元数据）
    /// - Parameter exercise: 听力练习
    /// - Returns: 生成的问题集
    private func generateBasicQuestions(for exercise: ListeningExercise) -> [ListeningQuestion] {
        // 从文件名提取可能的主题
        let fileName = exercise.audioFileName
        
        // 提取难度信息
        let difficulty = exercise.difficulty
        
        // 基于获取的信息生成简单问题
        var questions: [ListeningQuestion] = []
        
        // 问题1: 关于主题
        let topicQuestion = ListeningQuestion(
            id: UUID().uuidString,
            question: "这段音频主要讨论的是什么话题？",
            options: [
                "日常对话",
                "文化介绍",
                "语法讲解",
                "故事叙述"
            ],
            correctOptionIndex: 0,
            difficulty: difficulty
        )
        questions.append(topicQuestion)
        
        // 问题2: 关于难度
        let difficultyQuestion = ListeningQuestion(
            id: UUID().uuidString,
            question: "这段音频的语速如何？",
            options: [
                "非常缓慢，适合初学者",
                "中等语速，有少量停顿",
                "接近母语者自然语速",
                "非常快，难以跟上"
            ],
            correctOptionIndex: difficulty == .beginner ? 0 : (difficulty == .intermediate ? 1 : 2),
            difficulty: difficulty
        )
        questions.append(difficultyQuestion)
        
        // 问题3: 关于内容类型
        let contentQuestion = ListeningQuestion(
            id: UUID().uuidString,
            question: "这段音频最可能出现在哪种场景？",
            options: [
                "语言学习课程",
                "新闻报道",
                "电影对白",
                "广播节目"
            ],
            correctOptionIndex: 0,
            difficulty: difficulty
        )
        questions.append(contentQuestion)
        
        return questions
    }
    
    /// 生成备用问题（当所有其他方法失败时）
    private func generateFallbackQuestions() -> [ListeningQuestion] {
        return [
            ListeningQuestion(
                id: UUID().uuidString,
                question: "这段对话可能发生在什么地方？",
                options: ["咖啡馆", "学校", "公园", "超市"],
                correctOptionIndex: 0,
                difficulty: .beginner
            ),
            ListeningQuestion(
                id: UUID().uuidString,
                question: "对话中提到了几个人？",
                options: ["1个", "2个", "3个", "4个或更多"],
                correctOptionIndex: 1,
                difficulty: .beginner
            )
        ]
    }
    
    // 将难度枚举转换为字符串
    private func difficultyToString(_ difficulty: ListeningExercise.Difficulty) -> String {
        switch difficulty {
        case .beginner:
            return "beginner"
        case .intermediate:
            return "intermediate"
        case .advanced:
            return "advanced"
        }
    }
}

// MARK: - Errors

extension QuestionService {
    enum QuestionServiceError: Error, LocalizedError {
        case audioFileNotFound
        case transcriptionFailed
        case speechRecognizerNotAvailable
        case apiError(String)
        case invalidResponse
        case invalidURL
        case questionGenerationFailed
        
        var errorDescription: String? {
            switch self {
            case .audioFileNotFound:
                return "找不到音频文件"
            case .transcriptionFailed:
                return "音频转录失败"
            case .speechRecognizerNotAvailable:
                return "语音识别器不可用"
            case .apiError(let message):
                return "API错误: \(message)"
            case .invalidResponse:
                return "无效的响应"
            case .invalidURL:
                return "无效的URL"
            case .questionGenerationFailed:
                return "问题生成失败"
            }
        }
    }
}

// MARK: - Models

/// 问题数据模型
struct QuestionData: Codable {
    let question: String
    let options: [String]
    let correctOptionIndex: Int
    let transcript: String?
    let difficulty: String
    let tags: [String]
} 