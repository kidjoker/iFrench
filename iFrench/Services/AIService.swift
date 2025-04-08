import Foundation
import Combine

/// AI service for generating personalized content
class AIService: ObservableObject {
    /// Shared instance
    static let shared = AIService()
    
    /// Current message being displayed
    @Published var currentMessage: String = ""
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message if any
    @Published var errorMessage: String?
    
    /// API Key for Deepseek
    private var apiKey: String {
        Configuration.deepseekApiKey
    }
    
    /// Base URL for Deepseek API
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    
    /// Generate a personalized daily message
    /// - Parameters:
    ///   - user: Current user
    ///   - mascot: Selected mascot
    ///   - completion: Callback with the generated message
    func generateDailyMessage(user: User?, mascot: Mascot, completion: @escaping (String) -> Void) {
        guard Configuration.isApiKeyConfigured else {
            self.errorMessage = "API Key 未配置或无效"
            completion(getDefaultMessage())
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 构建提示信息
        var prompt = "你是一个专业的法语教师，需要生成一句鼓励学习者的话。"
        prompt += "请以\(mascot.name)的身份，"
        
        if let user = user {
            prompt += "对一个已经掌握了\(user.masteredWords)个单词、"
            prompt += "总学习时间为\(Int(user.totalDuration / 60))分钟、"
            prompt += "连续学习\(user.streak)天的学习者，"
        }
        
        prompt += """
        生成一句鼓励的话，要求：
        1. 首先用法语表达，然后用中文表达相同的意思
        2. 法语和中文之间用换行符分隔
        3. 法语部分要考虑学习者水平，使用简单易懂的表达
        4. 整体要体现温暖、友好和专业
        5. 回复格式示例：
        Bravo ! Tu as fait beaucoup de progrès. Continue comme ça !
        太棒了！你进步很多，继续保持！
        """
        
        // 构建API请求
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "system", "content": "你是一个专业的法语教师，精通法语和中文，擅长给出温暖、专业的双语建议。"],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 200
        ]
        
        guard let url = URL(string: baseURL) else {
            self.errorMessage = "无效的API URL"
            self.isLoading = false
            completion(getDefaultMessage())
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            self.errorMessage = "请求数据序列化失败"
            self.isLoading = false
            completion(getDefaultMessage())
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "网络请求失败: \(error.localizedDescription)"
                    completion(self?.getDefaultMessage() ?? "")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "无效的服务器响应"
                    completion(self?.getDefaultMessage() ?? "")
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "服务器错误: \(httpResponse.statusCode)"
                    completion(self?.getDefaultMessage() ?? "")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "服务器返回数据为空"
                    completion(self?.getDefaultMessage() ?? "")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        self?.currentMessage = content
                        completion(content)
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析API响应"])
                    }
                } catch {
                    self?.errorMessage = "解析响应失败: \(error.localizedDescription)"
                    completion(self?.getDefaultMessage() ?? "")
                }
            }
        }
        
        task.resume()
    }
    
    /// Get a default message when API is not available
    private func getDefaultMessage() -> String {
        let messages = [
            "Bonjour ! Prêt à apprendre le français aujourd'hui ?\n今天准备好学习法语了吗？",
            "Continue comme ça, tu fais des progrès !\n继续保持，你在进步！",
            "Chaque jour est une nouvelle opportunité d'apprendre !\n每一天都是学习的新机会！",
            "Petit à petit, l'oiseau fait son nid !\n积少成多，慢慢来！",
            "Tu es sur la bonne voie !\n你走在正确的道路上！"
        ]
        return messages.randomElement() ?? messages[0]
    }
}

extension Mascot {
    /// Mascot's display name in Chinese
    var name: String {
        switch self {
        case .frog:
            return "小青蛙"
        case .owl:
            return "智慧猫头鹰"
        case .fox:
            return "机灵小狐狸"
        }
    }
} 