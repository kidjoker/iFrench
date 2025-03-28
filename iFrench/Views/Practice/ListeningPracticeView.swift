//
//  ListeningPracticeView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct ListeningPracticeView: View {
    // Mock data for listening exercises
    let exercises = [
        "初级对话 1: 问候与自我介绍",
        "初级对话 2: 咖啡馆点餐",
        "初级对话 3: 购物对话",
        "中级对话 1: 预订酒店",
        "中级对话 2: 讨论天气",
        "高级对话 1: 法国文化讨论"
    ]
    
    @State private var selectedExercise: String?
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            // List of exercises
            List {
                ForEach(exercises, id: \.self) { exercise in
                    HStack {
                        Text(exercise)
                            .font(.body)
                    
                        Spacer()
                    
                        Image(systemName: selectedExercise == exercise ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedExercise == exercise ? .blue : .gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedExercise = exercise
                        isPlaying = false
                    }
                    .padding(.vertical, 8)
                }
            }
            #if os(iOS) || os(visionOS)
            .listStyle(InsetGroupedListStyle())
            #else
            .listStyle(DefaultListStyle())
            #endif
            
            // Audio player controls (mock)
            if let selectedExercise = selectedExercise {
                VStack(spacing: 15) {
                    Text(selectedExercise)
                        .font(.headline)
                    
                    // Mock playback progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: isPlaying ? geometry.size.width * 0.7 : 0, height: 8)
                                .cornerRadius(4)
                                .animation(.linear(duration: 5), value: isPlaying)
                        }
                    }
                    .frame(height: 8)
                    .padding(.vertical)
                    
                    // Playback controls
                    HStack(spacing: 30) {
                        Button(action: { 
                            // Rewind action would go here 
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            isPlaying.toggle()
                        }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: { 
                            // Forward action would go here 
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding()
            } else {
                Text("请选择一个听力练习")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationTitle("听力练习")
    }
}

#Preview {
    ListeningPracticeView()
} 