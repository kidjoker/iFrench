import Foundation

/// 听力练习问题模型
struct ListeningQuestion: Identifiable, Hashable {
    /// 唯一标识符
    let id: String
    
    /// 问题内容
    let question: String
    
    /// 选项列表
    let options: [String]
    
    /// 正确选项索引
    let correctOptionIndex: Int
    
    /// 问题难度
    let difficulty: ListeningExercise.Difficulty
    
    /// 用户选择的选项索引，如果尚未选择则为nil
    var userSelected: Int?
    
    /// 是否已回答正确
    var isCorrect: Bool {
        guard let userSelected = userSelected else { return false }
        return userSelected == correctOptionIndex
    }
    
    /// 是否已回答（无论对错）
    var isAnswered: Bool {
        return userSelected != nil
    }
} 