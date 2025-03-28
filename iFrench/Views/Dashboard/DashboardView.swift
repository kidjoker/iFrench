//
//  DashboardView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 欢迎消息和吉祥物
                MascotGreetingView(selectedMascot: $settings.selectedMascot)
                    .padding(.horizontal)
                
                // 学习统计卡片
                LearningStatsCard()
                    .padding(.horizontal)
                
                // 练习卡片网格
                VStack(spacing: 15) {
                    // 发音练习卡片
                    NavigationLink(destination: PronunciationPracticeView()) {
                        PracticeCard(
                            title: "发音练习",
                            description: "提高你的法语发音",
                            icon: "waveform",
                            color: .blue
                        )
                    }
                    
                    // 词汇复习卡片
                    NavigationLink(destination: VocabularyReviewView()) {
                        PracticeCard(
                            title: "词汇复习",
                            description: "巩固你学过的单词",
                            icon: "book.fill",
                            color: .green
                        )
                    }
                    
                    // 听力练习卡片
                    NavigationLink(destination: ListeningPracticeView()) {
                        PracticeCard(
                            title: "听力练习",
                            description: "训练你的法语听力",
                            icon: "ear.fill",
                            color: .purple
                        )
                    }
                }
                .padding(.horizontal)
                
                // 学习建议
                LearningTipsCard()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("iFrench")
        .toolbar {
            #if os(iOS) || os(visionOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView(settings: settings)) {
                    Image(systemName: "person.circle")
                        .font(.title2)
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                NavigationLink(destination: ProfileView(settings: settings)) {
                    Image(systemName: "person.circle")
                        .font(.title2)
                }
            }
            #endif
        }
    }
} 