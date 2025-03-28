//
//  ProfileView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

/// Profile view content
struct ProfileView: View {
    @EnvironmentObject private var authService: AuthService
    @ObservedObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                HStack(spacing: 15) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                    
                    // User info
                    VStack(alignment: .leading, spacing: 5) {
                        if let user = authService.currentUser {
                            Text(user.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                #if os(iOS) || os(visionOS)
                .background(Color(UIColor.systemBackground))
                #else
                .background(Color(.windowBackgroundColor))
                #endif
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Settings section
                VStack(alignment: .leading, spacing: 10) {
                    Text("设置")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        // Profile settings
                        SettingsRow(icon: "person.fill", title: "编辑个人资料", color: .blue)
                        
                        // Notification settings
                        SettingsRow(icon: "bell.fill", title: "通知设置", color: .orange)
                        
                        // Language settings
                        SettingsRow(icon: "globe", title: "语言设置", color: .green)
                        
                        // Appearance settings
                        SettingsRow(icon: "paintbrush.fill", title: "外观设置", color: .purple)
                    }
                    .padding(.horizontal)
                }
                
                // Support section
                VStack(alignment: .leading, spacing: 10) {
                    Text("支持")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        // Help center
                        SettingsRow(icon: "questionmark.circle", title: "帮助中心", color: .teal)
                        
                        // Contact us
                        SettingsRow(icon: "envelope.fill", title: "联系我们", color: .blue)
                        
                        // Privacy Policy
                        SettingsRow(icon: "lock.fill", title: "隐私政策", color: .gray)
                    }
                    .padding(.horizontal)
                }
                
                // Logout button
                Button(action: {
                    // 退出登录
                    authService.logout()
                    // 在 TabView 内时，可能需要返回到根视图
                    presentationMode.wrappedValue.dismiss()
                    // 注意：因为我们在 App 入口处已经设置了根据登录状态显示不同视图
                    // 所以退出登录后会自动切换到登录视图
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16))
                        Text("退出登录")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .red.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("个人资料")
    }
}

/// Settings row component
struct SettingsRow: View {
    var icon: String
    var title: String
    var color: Color
    
    var body: some View {
        Button(action: {
            // Handle row tap
        }) {
            HStack(spacing: 15) {
                // Icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity)
            #if os(iOS) || os(visionOS)
            .background(Color(UIColor.systemBackground))
            #else
            .background(Color(.windowBackgroundColor))
            #endif
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(settings: AppSettings())
            .environmentObject(AuthService.shared)
    }
} 