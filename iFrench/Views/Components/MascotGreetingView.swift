//
//  MascotGreetingView.swift
//  iFrench
//
//  Created by kidjoker on 2025-03-25.
//

import SwiftUI

struct MascotGreetingView: View {
    @ObservedObject var settings: AppSettings
    
    var body: some View {
        HStack(spacing: 15) {
            // 吉祥物图像 - Using system image as a fallback instead of a custom image that might not exist
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 70, height: 70)
                .overlay(
                    getMascotImage()
                )
            
            // 欢迎信息
            VStack(alignment: .leading, spacing: 5) {
                Text("你好！")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("今天是学习法语的好日子！")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // Get the appropriate mascot image
    @ViewBuilder
    private func getMascotImage() -> some View {
        // Using system images as fallbacks since we may not have the actual mascot images
        switch settings.selectedMascot {
        case .frog:
            Image(systemName: "tortoise.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
        case .owl:
            Image(systemName: "owl")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.brown)
        case .fox:
            Image(systemName: "hare.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.orange)
        }
    }
} 