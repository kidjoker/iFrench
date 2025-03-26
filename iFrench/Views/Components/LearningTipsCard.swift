//
//  LearningTipsCard.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct LearningTipsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 标题
            Text("学习建议")
                .font(.headline)
            
            // 提示列表
            VStack(alignment: .leading, spacing: 10) {
                TipRow(icon: "ear.fill", color: .blue, text: "每天听10分钟的法语音频，提高听力理解能力")
                TipRow(icon: "mouth.fill", color: .red, text: "练习发音时，注意嘴型和舌位，多次重复")
                TipRow(icon: "book.fill", color: .green, text: "使用间隔复习法学习词汇，效果更好")
                TipRow(icon: "speaker.wave.2.fill", color: .purple, text: "尝试跟读法语对话，提高口语流利度")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct TipRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // 图标
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            // 文本
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
} 