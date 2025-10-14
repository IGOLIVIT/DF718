//
//  MiniGameView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct MiniGameView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var gameState: GameState = .menu
    
    enum GameState {
        case menu
        case playing
        case gameOver
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                switch gameState {
                case .menu:
                    GameMenuView(
                        userProgress: userProgress,
                        onStartGame: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                gameState = .playing
                            }
                        },
                        onDismiss: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    
                case .playing:
                    EnergyCatchGameView(
                        userProgress: userProgress,
                        onGameOver: { score in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                gameState = .gameOver
                            }
                        }
                    )
                    
                case .gameOver:
                    GameOverView(
                        userProgress: userProgress,
                        onPlayAgain: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                gameState = .playing
                            }
                        },
                        onBackToMenu: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                gameState = .menu
                            }
                        }
                    )
                }
            }
        }
    }
}

struct GameMenuView: View {
    @ObservedObject var userProgress: UserProgress
    let onStartGame: () -> Void
    let onDismiss: () -> Void
    
    @State private var titleScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // Game Title and Description
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.secondaryAccent)
                        .scaleEffect(titleScale)
                        .animation(.spring(response: 1.0, dampingFraction: 0.6).repeatForever(autoreverses: true), value: titleScale)
                    
                    Text("Energy Catch")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Catch the falling energy orbs and avoid the obstacles!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Game Instructions
                VStack(spacing: 12) {
                    GameInstructionRow(icon: "star.fill", text: "Catch golden orbs for points", color: AppColors.secondaryAccent)
                    GameInstructionRow(icon: "xmark.circle.fill", text: "Avoid red obstacles", color: AppColors.primaryAccent)
                    GameInstructionRow(icon: "bolt.fill", text: "Speed increases over time", color: AppColors.textSecondary)
                    GameInstructionRow(icon: "heart.fill", text: "You have 3 lives to start", color: AppColors.primaryAccent)
                    GameInstructionRow(icon: "trophy.fill", text: "Earn Energy Orbs based on score", color: AppColors.secondaryAccent)
                }
                .padding(.horizontal, 40)
                
                // High Score Display
                VStack(spacing: 8) {
                    Text("Your Best")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(userProgress.energyOrbs * 50)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.secondaryAccent)
                    
                    Text("points")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.secondaryAccent.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 40)
            }
            .opacity(buttonOpacity)
            .animation(.easeInOut(duration: 0.8).delay(0.3), value: buttonOpacity)
            
            Spacer()
            
            // Start Game Button
            Button(action: onStartGame) {
                HStack(spacing: 12) {
                    Text("Start Game")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppColors.primaryAccent.opacity(0.3), radius: 15, x: 0, y: 8)
                )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .opacity(buttonOpacity)
            .animation(.easeInOut(duration: 0.8).delay(0.6), value: buttonOpacity)
        }
        .onAppear {
            titleScale = 1.1
            buttonOpacity = 1.0
        }
    }
}

struct GameInstructionRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
    }
}

struct EnergyCatchGameView: View {
    @ObservedObject var userProgress: UserProgress
    let onGameOver: (Int) -> Void
    
    @State private var score = 0
    @State private var lives = 3
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    @State private var fallingObjects: [FallingObject] = []
    @State private var gameSpeed: Double = 1.0
    @State private var gameTime: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game Area
                Rectangle()
                    .fill(AppColors.background)
                    .ignoresSafeArea()
                
                // Falling Objects
                ForEach(fallingObjects) { object in
                    FallingObjectView(object: object)
                        .position(object.position)
                        .onTapGesture {
                            catchObject(object, in: geometry)
                        }
                }
                
                // Game UI
                VStack {
                    // Top HUD
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Score")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(score)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.secondaryAccent)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ForEach(0..<lives, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primaryAccent)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Game Instructions
                    Text("Tap to catch!")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary.opacity(0.8))
                        .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        score = 0
        lives = 3
        gameSpeed = 1.0
        gameTime = 0
        fallingObjects.removeAll()
        
        // Main game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateGame()
        }
        
        // Object spawn timer
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            spawnObject()
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }
    
    private func updateGame() {
        gameTime += 0.016
        
        // Increase speed over time
        gameSpeed = 1.0 + (gameTime / 30.0)
        
        // Update object positions
        for i in fallingObjects.indices {
            fallingObjects[i].position.y += CGFloat(2.0 * gameSpeed)
        }
        
        // Remove objects that have fallen off screen
        fallingObjects.removeAll { object in
            if object.position.y > UIScreen.main.bounds.height + 50 {
                if object.isCorrect {
                    // Lost a life for missing a good object
                    lives -= 1
                    if lives <= 0 {
                        endGame()
                    }
                }
                return true
            }
            return false
        }
    }
    
    private func spawnObject() {
        let screenWidth = UIScreen.main.bounds.width
        let x = CGFloat.random(in: 50...(screenWidth - 50))
        let isCorrect = Bool.random() ? true : (Bool.random() ? false : true) // 66% chance for good objects
        
        let object = FallingObject(
            position: CGPoint(x: x, y: -50),
            isCorrect: isCorrect,
            symbol: isCorrect ? "star.fill" : "xmark.circle.fill",
            color: isCorrect ? AppColors.secondaryAccent : AppColors.primaryAccent
        )
        
        fallingObjects.append(object)
    }
    
    private func catchObject(_ object: FallingObject, in geometry: GeometryProxy) {
        guard let index = fallingObjects.firstIndex(where: { $0.id == object.id }) else { return }
        
        fallingObjects.remove(at: index)
        
        if object.isCorrect {
            score += 10
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        } else {
            lives -= 1
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            if lives <= 0 {
                endGame()
            }
        }
    }
    
    private func endGame() {
        stopGame()
        
        // Award energy orbs based on score
        let orbsEarned = max(1, score / 50)
        userProgress.energyOrbs += orbsEarned
        userProgress.addPlaytime(gameTime)
        userProgress.saveProgress()
        
        onGameOver(score)
    }
}

struct FallingObjectView: View {
    let object: FallingObject
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(object.color.opacity(0.2))
                .frame(width: 50, height: 50)
            
            Image(systemName: object.symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(object.color)
        }
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

struct GameOverView: View {
    @ObservedObject var userProgress: UserProgress
    let onPlayAgain: () -> Void
    let onBackToMenu: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primaryAccent)
                    .opacity(showContent ? 1.0 : 0.0)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
                
                Text("Game Over!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.4), value: showContent)
                
                Text("You earned Energy Orbs!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.secondaryAccent)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: showContent)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(AppColors.primaryAccent)
                        )
                }
                
                Button(action: onBackToMenu) {
                    Text("Back to Menu")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(AppColors.textSecondary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(0.8), value: showContent)
        }
        .onAppear {
            showContent = true
        }
    }
}

#Preview {
    MiniGameView(userProgress: UserProgress())
}
