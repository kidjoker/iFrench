import Foundation

/// Configuration manager for app settings and API keys
enum Configuration {
    /// Get value from Info.plist
    private static func value<T>(for key: String) -> T? {
        Bundle.main.object(forInfoDictionaryKey: key) as? T
    }
    
    /// Deepseek API Key
    static var deepseekApiKey: String {
        #if DEBUG
        return "sk-1a163a7f7b33413eb2294cca82c7a795"  // 直接使用 Config.xcconfig 中的值
        #else
        // 从Info.plist获取（通过xcconfig注入）
        if let key = value(for: "DEEPSEEK_API_KEY") as? String, !key.isEmpty {
            return key
        }
        return ""  // 如果获取失败返回空字符串
        #endif
    }
    
    /// Google Cloud API Key
    static var googleCloudApiKey: String {
        #if DEBUG
        return "AIzaSyC8qrUfOyNOirUJKNgUGl0SSgjYh2TAHFs"  // 直接使用 Config.xcconfig 中的值
        #else
        // 从Info.plist获取（通过xcconfig注入）
        if let key = value(for: "GOOGLE_CLOUD_API_KEY") as? String, !key.isEmpty {
            return key
        }
        return ""  // 如果获取失败返回空字符串
        #endif
    }
    
    /// Speech Recognition Usage Description
    static var speechRecognitionUsageDescription: String {
        return value(for: "NSSpeechRecognitionUsageDescription") ?? "我们需要语音识别权限来转录和分析法语音频内容，从而生成相关问题。"
    }
    
    /// Microphone Usage Description
    static var microphoneUsageDescription: String {
        return value(for: "NSMicrophoneUsageDescription") ?? "我们需要麦克风权限来记录您的法语发音，以便进行评估和改进建议。"
    }
    
    /// Check if API key is properly configured
    static var isApiKeyConfigured: Bool {
        !deepseekApiKey.isEmpty
    }
} 