//
//  DailyChallengeView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct DailyChallengeView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    @State private var gamePhase: GamePhase = .showing
    @State private var userAnswer: [Int] = []
    @State private var correctPattern: [Int] = []
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var timeRemaining = 3
    @State private var timer: Timer?
    @State private var currentPatternIndex = 0
    @State private var highlightedColor: Int? = nil
    
    enum GamePhase {
        case showing    // Показываем паттерн
        case input      // Пользователь вводит ответ
        case result     // Показываем результат
    }
    
    let colors: [Color] = [AppColors.primaryAccent, AppColors.secondaryAccent, .blue, .green]
    let maxSteps = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("Daily Mind Challenge")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("Step \(currentStep + 1)/\(maxSteps)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.secondaryAccent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    if showResult {
                        // Result Screen
                        VStack(spacing: 30) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(isCorrect ? AppColors.secondaryAccent.opacity(0.2) : AppColors.primaryAccent.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(isCorrect ? AppColors.secondaryAccent : AppColors.primaryAccent)
                            }
                            
                            VStack(spacing: 16) {
                                Text(isCorrect ? "Excellent!" : "Good Try!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                if isCorrect {
                                    Text("You earned +2 Energy Orbs!")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.secondaryAccent)
                                } else {
                                    Text("Keep practicing to improve your recall!")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if currentStep < maxSteps - 1 {
                                    nextChallenge()
                                } else {
                                    completeChallenge()
                                }
                            }) {
                                Text(currentStep < maxSteps - 1 ? "Next Challenge" : "Complete")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(AppColors.primaryAccent)
                                    )
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                        }
                    } else {
                        // Challenge Screen
                        VStack(spacing: 40) {
                            // Instructions
                            VStack(spacing: 16) {
                                switch gamePhase {
                                case .showing:
                                    Text("Watch the Pattern")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Memorize the sequence of colors")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.secondaryAccent)
                                    
                                case .input:
                                    Text("Repeat the Pattern")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Tap the colors in the same order (\(userAnswer.count)/\(correctPattern.count))")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                case .result:
                                    Text("Result")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            
                            // Color Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                                ForEach(0..<4, id: \.self) { index in
                                    ColorButton(
                                        color: colors[index],
                                        index: index,
                                        isHighlighted: highlightedColor == index,
                                        isSelected: userAnswer.contains(index),
                                        action: {
                                            if gamePhase == .input {
                                                selectColor(index)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            if gamePhase == .input && userAnswer.count == correctPattern.count {
                                Button(action: checkAnswer) {
                                    Text("Check Answer")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(
                                            RoundedRectangle(cornerRadius: 28)
                                                .fill(AppColors.primaryAccent)
                                        )
                                }
                                .padding(.horizontal, 40)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear {
            startChallenge()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startChallenge() {
        generatePattern()
        gamePhase = .showing
        userAnswer = []
        showResult = false
        currentPatternIndex = 0
        highlightedColor = nil
        
        // Начинаем показ паттерна
        showPatternSequence()
    }
    
    private func generatePattern() {
        let patternLength = min(2 + currentStep, 5) // Начинаем с 2, максимум 5
        correctPattern = (0..<patternLength).map { _ in Int.random(in: 0..<4) }
    }
    
    private func showPatternSequence() {
        guard currentPatternIndex < correctPattern.count else {
            // Паттерн показан полностью, переходим к вводу
            gamePhase = .input
            highlightedColor = nil
            return
        }
        
        // Подсвечиваем текущий цвет
        highlightedColor = correctPattern[currentPatternIndex]
        
        // Через 0.8 секунды убираем подсветку и показываем следующий
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            highlightedColor = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentPatternIndex += 1
                showPatternSequence()
            }
        }
    }
    
    private func selectColor(_ index: Int) {
        userAnswer.append(index)
        
        // Проверяем правильность сразу
        if userAnswer.count <= correctPattern.count {
            let isCurrentCorrect = userAnswer[userAnswer.count - 1] == correctPattern[userAnswer.count - 1]
            
            if !isCurrentCorrect {
                // Неправильный ответ - сразу показываем результат
                isCorrect = false
                gamePhase = .result
                showResult = true
            } else if userAnswer.count == correctPattern.count {
                // Все правильно - автоматически проверяем
                checkAnswer()
            }
        }
    }
    
    private func checkAnswer() {
        isCorrect = userAnswer == correctPattern
        gamePhase = .result
        showResult = true
        
        if isCorrect {
            userProgress.energyOrbs += 2
            userProgress.saveProgress()
        }
    }
    
    private func nextChallenge() {
        currentStep += 1
        startChallenge()
    }
    
    private func completeChallenge() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct ColorButton: View {
    let color: Color
    let index: Int
    let isHighlighted: Bool
    let isSelected: Bool
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isHighlighted ? Color.white : (isSelected ? AppColors.textPrimary : Color.clear),
                            lineWidth: isHighlighted || isSelected ? 4 : 0
                        )
                )
                .scaleEffect(isHighlighted ? 1.1 : (isSelected ? 1.05 : 1.0))
                .shadow(color: color.opacity(0.3), radius: isHighlighted ? 15 : 5, x: 0, y: 5)
        }
        .scaleEffect(scale)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = pressing ? 0.95 : 1.0
            }
        }, perform: {})
    }
}

#Preview {
    DailyChallengeView(userProgress: UserProgress())
}
