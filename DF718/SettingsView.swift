//
//  SettingsView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var showResetAlert = false
    @State private var cardOpacity: Double = 1.0
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    AppColors.background
                        .ignoresSafeArea()
                    
                    // Background decoration
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(AppColors.primaryAccent.opacity(0.03))
                            .frame(width: CGFloat.random(in: 100...200))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 6...12))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...3)),
                                value: cardOpacity
                            )
                    }
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Header
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                                
                                Text("Settings")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                // Placeholder for symmetry
                                Color.clear
                                    .frame(width: 20, height: 20)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            // Statistics Section
                            VStack(spacing: 20) {
                                SectionHeader(title: "Your Statistics", icon: "chart.bar.fill")
                                
                                VStack(spacing: 16) {
                                    StatisticCard(
                                        title: "Energy Orbs Collected",
                                        value: "\(userProgress.energyOrbs)",
                                        icon: "star.fill",
                                        color: AppColors.secondaryAccent
                                    )
                                    
                                    StatisticCard(
                                        title: "Current Level",
                                        value: "\(userProgress.currentLevel)",
                                        icon: "trophy.fill",
                                        color: AppColors.primaryAccent
                                    )
                                    
                                    StatisticCard(
                                        title: "Lessons Completed",
                                        value: "\(userProgress.totalLessonsCompleted)",
                                        icon: "book.fill",
                                        color: AppColors.secondaryAccent
                                    )
                                    
                                    StatisticCard(
                                        title: "Total Playtime",
                                        value: userProgress.formattedPlaytime,
                                        icon: "clock.fill",
                                        color: AppColors.primaryAccent
                                    )
                                    
                                    StatisticCard(
                                        title: "Modules Completed",
                                        value: "\(userProgress.completedModules.count)/\(SkillModule.sampleModules.count)",
                                        icon: "checkmark.circle.fill",
                                        color: AppColors.secondaryAccent
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Actions Section
                            VStack(spacing: 20) {
                                SectionHeader(title: "Actions", icon: "gear")
                                
                                VStack(spacing: 16) {
                                    ActionCard(
                                        title: "Reset Progress",
                                        subtitle: "Clear all statistics and start fresh",
                                        icon: "arrow.clockwise",
                                        color: AppColors.primaryAccent,
                                        action: {
                                            showResetAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    userProgress.resetProgress()
                }
            }
        } message: {
            Text("Are you sure you want to reset all your progress? This action cannot be undone.")
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        cardOpacity = 1.0
        cardOffset = 0
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppColors.primaryAccent)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}


#Preview {
    SettingsView(userProgress: UserProgress())
}
