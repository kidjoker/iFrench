//
//  ProfileView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var settings: AppSettings
    
    @State private var showingMascotPicker = false
    
    var body: some View {
        Form {
            Section(header: Text("个人信息")) {
                HStack {
                    Text("用户名")
                    Spacer()
                    Text("学习者")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("学习等级")
                    Spacer()
                    Text("初级")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("连续学习天数")
                    Spacer()
                    Text("7")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("应用设置")) {
                Toggle("深色模式", isOn: $settings.isDarkMode)
                
                Picker("文字大小", selection: $settings.textSize) {
                    ForEach(AppSettings.TextSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                
                Button(action: { showingMascotPicker = true }) {
                    HStack {
                        Text("学习助手")
                        Spacer()
                        Text(settings.selectedMascot.rawValue)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .sheet(isPresented: $showingMascotPicker) {
                    MascotPickerView(selection: $settings.selectedMascot)
                }
            }
            
            Section(header: Text("关于")) {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    Text("反馈问题")
                }
                
                Button(action: {}) {
                    Text("隐私政策")
                }
            }
        }
        .navigationTitle("个人中心")
    }
}

struct MascotPickerView: View {
    @Binding var selection: Mascot
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Mascot.allCases) { mascot in
                    Button(action: {
                        selection = mascot
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            // Using system images for mascots
                            Circle()
                                .fill(getMascotColor(mascot).opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    getMascotSystemImage(mascot)
                                )
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(mascot.rawValue)
                                    .font(.headline)
                                
                                Text(mascot.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                            
                            if mascot == selection {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("选择学习助手")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // Get the appropriate mascot image
    @ViewBuilder
    private func getMascotSystemImage(_ mascot: Mascot) -> some View {
        switch mascot {
        case .frog:
            Image(systemName: "tortoise.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.green)
        case .owl:
            Image(systemName: "owl")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.brown)
        case .fox:
            Image(systemName: "hare.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.orange)
        }
    }
    
    // Get the appropriate color for each mascot
    private func getMascotColor(_ mascot: Mascot) -> Color {
        switch mascot {
        case .frog: return .green
        case .owl: return .brown
        case .fox: return .orange
        }
    }
} 