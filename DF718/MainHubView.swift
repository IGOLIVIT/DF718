//
//  MainHubView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct MainHubView: View {
    @ObservedObject var userProgress: UserProgress
    @State private var showSkillArena = false
    @State private var showMiniGame = false
    @State private var showSettings = false
    @State private var cardScale: CGFloat = 0.9
    @State private var headerOpacity: Double = 0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    AppColors.background
                        .ignoresSafeArea()
                    
                    // Animated background elements
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(AppColors.secondaryAccent.opacity(0.05))
                            .frame(width: CGFloat.random(in: 60...120))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 4...8))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...3)),
                                value: cardScale
                            )
                            .scaleEffect(cardScale)
                    }
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Header with stats
                            VStack(spacing: 20) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Choose Your Path")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundColor(AppColors.textPrimary)
                                        
                                        Text("Level \(userProgress.currentLevel)")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showSettings = true
                                    }) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                                
                                // Energy Orbs and Level Progress
                                VStack(spacing: 12) {
                                    HStack {
                                        HStack(spacing: 8) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(AppColors.secondaryAccent)
                                            
                                            Text("\(userProgress.energyOrbs)")
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                                .foregroundColor(AppColors.textPrimary)
                                            
                                            Text("Energy Orbs")
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    // Level Progress Bar
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text("Progress to Level \(userProgress.currentLevel + 1)")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(AppColors.textSecondary)
                                            Spacer()
                                            Text("\(Int(userProgress.levelProgress * 100))%")
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(AppColors.secondaryAccent)
                                        }
                                        
                                        ProgressView(value: userProgress.levelProgress)
                                            .progressViewStyle(CustomProgressViewStyle())
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            // Navigation Cards
                            VStack(spacing: 20) {
                                // Learn Skills Card
                                NavigationCard(
                                    title: "Learn Skills",
                                    subtitle: "Enhance your cognitive abilities",
                                    icon: "brain.head.profile",
                                    color: AppColors.primaryAccent,
                                    action: {
                                        showSkillArena = true
                                    }
                                )
                                
                                // Play Game Card
                                NavigationCard(
                                    title: "Play Game",
                                    subtitle: "Fun challenges and mini-games",
                                    icon: "gamecontroller.fill",
                                    color: AppColors.secondaryAccent,
                                    action: {
                                        showMiniGame = true
                                    }
                                )
                            }
                            .padding(.horizontal, 24)
                            
                            // Daily Challenge Section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Daily Challenge")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Text("🔥 \(userProgress.currentLevel)")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.secondaryAccent)
                                }
                                
                                DailyChallengeCard(userProgress: userProgress)
                            }
                            .padding(.horizontal, 24)
                            
                            // Quick Stats Section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Your Progress")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                }
                                
                                HStack(spacing: 12) {
                                    QuickStatCard(
                                        title: "Streak",
                                        value: "\(userProgress.currentLevel)",
                                        icon: "flame.fill",
                                        color: AppColors.primaryAccent
                                    )
                                    
                                    QuickStatCard(
                                        title: "Best Score",
                                        value: "\(userProgress.energyOrbs * 10)",
                                        icon: "star.fill",
                                        color: AppColors.secondaryAccent
                                    )
                                    
                                    QuickStatCard(
                                        title: "Rank",
                                        value: "#\(max(1, 100 - userProgress.totalLessonsCompleted))",
                                        icon: "trophy.fill",
                                        color: AppColors.primaryAccent
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Recent Achievements
                            if userProgress.totalLessonsCompleted > 0 {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Recent Achievements")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                    }
                                    
                                    VStack(spacing: 12) {
                                        if userProgress.totalLessonsCompleted >= 5 {
                                            AchievementCard(
                                                title: "Learning Master",
                                                description: "Completed 5 lessons",
                                                icon: "graduationcap.fill",
                                                isUnlocked: true
                                            )
                                        }
                                        
                                        if userProgress.energyOrbs >= 10 {
                                            AchievementCard(
                                                title: "Energy Collector",
                                                description: "Collected 10 Energy Orbs",
                                                icon: "star.circle.fill",
                                                isUnlocked: true
                                            )
                                        }
                                        
                                        if userProgress.currentLevel >= 3 {
                                            AchievementCard(
                                                title: "Rising Star",
                                                description: "Reached Level 3",
                                                icon: "sparkles",
                                                isUnlocked: true
                                            )
                                        }
                                        
                                        // Locked achievements
                                        if userProgress.totalLessonsCompleted < 20 {
                                            AchievementCard(
                                                title: "Expert Learner",
                                                description: "Complete 20 lessons",
                                                icon: "brain.head.profile",
                                                isUnlocked: false
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSkillArena) {
            SkillArenaView(userProgress: userProgress)
        }
        .sheet(isPresented: $showMiniGame) {
            MiniGameView(userProgress: userProgress)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(userProgress: userProgress)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        cardScale = 1.0
        headerOpacity = 1.0
    }
}

struct NavigationCard: View {
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
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(AppColors.textSecondary.opacity(0.2))
                .frame(height: 8)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [AppColors.secondaryAccent, AppColors.primaryAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: (configuration.fractionCompleted ?? 0) * 200, height: 8)
                .animation(.easeInOut(duration: 0.5), value: configuration.fractionCompleted)
        }
        .frame(maxWidth: 200)
    }
}

struct DailyChallengeCard: View {
    @ObservedObject var userProgress: UserProgress
    @State private var showDailyChallenge = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            showDailyChallenge = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.secondaryAccent.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(AppColors.secondaryAccent)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quick Mind Test")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Complete today's challenge for bonus orbs")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack {
                        Text("Reward: +2 Energy Orbs")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.secondaryAccent)
                        
                        Spacer()
                        
                        Text("5 min")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.secondaryAccent)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.secondaryAccent.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: AppColors.secondaryAccent.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .sheet(isPresented: $showDailyChallenge) {
            DailyChallengeView(userProgress: userProgress)
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppColors.secondaryAccent.opacity(0.2) : AppColors.textSecondary.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isUnlocked ? AppColors.secondaryAccent : AppColors.textSecondary.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isUnlocked ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.7))
                
                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isUnlocked ? AppColors.textSecondary : AppColors.textSecondary.opacity(0.5))
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.secondaryAccent)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isUnlocked ? AppColors.secondaryAccent.opacity(0.3) : AppColors.textSecondary.opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

#Preview {
    MainHubView(userProgress: UserProgress())
}
