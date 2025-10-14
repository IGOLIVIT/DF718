//
//  SkillArenaView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct SkillArenaView: View {
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedModule: SkillModule?
    @State private var showModuleDetail = false
    @State private var cardAnimationOffset: CGFloat = 100
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    AppColors.background
                        .ignoresSafeArea()
                    
                    // Background animation elements
                    ForEach(0..<6, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.primaryAccent.opacity(0.03))
                            .frame(
                                width: CGFloat.random(in: 80...150),
                                height: CGFloat.random(in: 80...150)
                            )
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .rotationEffect(.degrees(Double.random(in: 0...360)))
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 5...10))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...2)),
                                value: cardOpacity
                            )
                    }
                    
                    VStack(spacing: 0) {
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
                            
                            Text("Skill Arena")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            // Placeholder for symmetry
                            Color.clear
                                .frame(width: 20, height: 20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        
                        // Progress Overview
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Progress")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("\(userProgress.completedModules.count) of \(SkillModule.sampleModules.count) modules completed")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                CircularProgressView(
                                    progress: Double(userProgress.completedModules.count) / Double(SkillModule.sampleModules.count),
                                    size: 60
                                )
                            }
                            .padding(.horizontal, 24)
                            
                            // Category Filters
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    CategoryChip(title: "All", isSelected: true)
                                    CategoryChip(title: "Mind", isSelected: false)
                                    CategoryChip(title: "Focus", isSelected: false)
                                    CategoryChip(title: "Logic", isSelected: false)
                                    CategoryChip(title: "Creative", isSelected: false)
                                    CategoryChip(title: "Social", isSelected: false)
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Skill Modules List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(SkillModule.sampleModules, id: \.id) { module in
                                    SkillModuleCard(
                                        module: module,
                                        isCompleted: userProgress.completedModules.contains(module.moduleId),
                                        action: {
                                            print("Selected module: \(module.title) with \(module.tasks.count) tasks")
                                            selectedModule = module
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                showModuleDetail = true
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 50)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showModuleDetail) {
            if let module = selectedModule, !module.tasks.isEmpty {
                SkillModuleDetailView(module: module, userProgress: userProgress)
            } else {
                // Fallback view if module is nil or empty
                VStack(spacing: 20) {
                    Text("Module not available")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Button("Close") {
                        showModuleDetail = false
                    }
                    .foregroundColor(AppColors.primaryAccent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        cardAnimationOffset = 0
        cardOpacity = 1.0
    }
}

struct SkillModuleCard: View {
    let module: SkillModule
    let isCompleted: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            HStack(spacing: 20) {
                // Icon and Status
                ZStack {
                    Circle()
                        .fill(isCompleted ? AppColors.secondaryAccent.opacity(0.2) : AppColors.primaryAccent.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.secondaryAccent)
                    } else {
                        Image(systemName: module.icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(AppColors.primaryAccent)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(module.title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        if isCompleted {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.secondaryAccent)
                        }
                        
                        Spacer()
                    }
                    
                    Text(module.description)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("\(module.tasks.count) tasks")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary.opacity(0.8))
                        
                        Spacer()
                        
                        if isCompleted {
                            Text("Completed")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.secondaryAccent)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primaryAccent)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCompleted ? AppColors.secondaryAccent.opacity(0.3) : AppColors.primaryAccent.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: (isCompleted ? AppColors.secondaryAccent : AppColors.primaryAccent).opacity(0.15),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct SkillModuleDetailView: View {
    let module: SkillModule
    @ObservedObject var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentTaskIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCompletion = false
    @State private var taskProgress: Double = 0
    @State private var isDataReady = false
    
    var currentTask: SkillTask {
        guard !module.tasks.isEmpty && currentTaskIndex < module.tasks.count else {
            return SkillTask(
                question: "Loading...",
                options: ["Loading...", "Loading...", "Loading...", "Loading..."],
                correctAnswer: 0,
                explanation: "Loading..."
            )
        }
        return module.tasks[currentTaskIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                if showCompletion {
                    CompletionView(
                        module: module,
                        userProgress: userProgress,
                        onDismiss: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                } else if !isDataReady {
                    // Loading screen with proper background
                    VStack(spacing: 30) {
                        // Header with close button
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text("Loading...")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            // Placeholder for symmetry
                            Color.clear
                                .frame(width: 20, height: 20)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryAccent))
                                .scaleEffect(1.5)
                            
                            Text("Preparing \(module.title)...")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                } else {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 20) {
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text(module.title)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text("\(currentTaskIndex + 1)/\(module.tasks.count)")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.secondaryAccent)
                            }
                            
                            // Progress Bar
                            ProgressView(value: taskProgress)
                                .progressViewStyle(CustomProgressViewStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Task Content
                        ScrollView {
                            VStack(spacing: 30) {
                            // Question
                            VStack(spacing: 16) {
                                Text("Question \(currentTaskIndex + 1)")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppColors.secondaryAccent)
                                
                                Text(currentTask.question)
                                    .font(.system(size: 22, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                                
                                // Answer Options
                                VStack(spacing: 12) {
                                    ForEach(Array(currentTask.options.enumerated()), id: \.offset) { index, option in
                                        AnswerButton(
                                            text: option,
                                            isSelected: selectedAnswer == index,
                                            isCorrect: showResult && index == currentTask.correctAnswer,
                                            isWrong: showResult && selectedAnswer == index && index != currentTask.correctAnswer,
                                            action: {
                                                if !showResult {
                                                    selectedAnswer = index
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                                
                                // Result and Explanation
                                if showResult {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(isCorrect ? AppColors.secondaryAccent : AppColors.primaryAccent)
                                            
                                            Text(isCorrect ? "Correct!" : "Not quite right")
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                                .foregroundColor(AppColors.textPrimary)
                                        }
                                        
                                        Text(currentTask.explanation)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(AppColors.cardBackground)
                                    )
                                    .padding(.horizontal, 24)
                                }
                                
                                Spacer(minLength: 100)
                            }
                        }
                        
                        // Action Button
                        VStack {
                            if selectedAnswer != nil && !showResult {
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
                                .padding(.horizontal, 24)
                            } else if showResult {
                                Button(action: nextTask) {
                                    Text(currentTaskIndex < module.tasks.count - 1 ? "Next Question" : "Complete Module")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(
                                            RoundedRectangle(cornerRadius: 28)
                                                .fill(AppColors.secondaryAccent)
                                        )
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .onAppear {
            // Принудительная инициализация с задержкой для загрузки данных
            isDataReady = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Убеждаемся что все переменные инициализированы
                if currentTaskIndex >= module.tasks.count {
                    currentTaskIndex = 0
                }
                selectedAnswer = nil
                showResult = false
                showCompletion = false
                updateProgress()
                
                // Данные готовы
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDataReady = true
                }
            }
        }
    }
    
    private func updateProgress() {
        taskProgress = Double(currentTaskIndex) / Double(module.tasks.count)
    }
    
    private func checkAnswer() {
        guard let answer = selectedAnswer else { return }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isCorrect = answer == currentTask.correctAnswer
            showResult = true
        }
    }
    
    private func nextTask() {
        if currentTaskIndex < module.tasks.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentTaskIndex += 1
                selectedAnswer = nil
                showResult = false
                updateProgress()
            }
        } else {
            // Complete module
            userProgress.completeModule(module.moduleId)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showCompletion = true
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return AppColors.secondaryAccent.opacity(0.2)
        } else if isWrong {
            return AppColors.primaryAccent.opacity(0.2)
        } else if isSelected {
            return AppColors.primaryAccent.opacity(0.1)
        } else {
            return AppColors.cardBackground
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return AppColors.secondaryAccent
        } else if isWrong {
            return AppColors.primaryAccent
        } else if isSelected {
            return AppColors.primaryAccent
        } else {
            return AppColors.textSecondary.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.secondaryAccent)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primaryAccent)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
            )
        }
    }
}

struct CompletionView: View {
    let module: SkillModule
    @ObservedObject var userProgress: UserProgress
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var orbScale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Celebration Icon
            ZStack {
                Circle()
                    .fill(AppColors.secondaryAccent.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.secondaryAccent)
                    .scaleEffect(orbScale)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).repeatCount(3, autoreverses: true), value: orbScale)
            }
            
            VStack(spacing: 16) {
                Text("Module Complete!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("You've earned +1 Energy Orb")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.secondaryAccent)
                
                Text("Great job completing \(module.title)! Your mind is getting stronger.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8).delay(0.5), value: showContent)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Continue")
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
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8).delay(1.0), value: showContent)
        }
        .onAppear {
            showContent = true
            orbScale = 1.2
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 4)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AppColors.primaryAccent : AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? AppColors.primaryAccent : AppColors.textSecondary.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
    }
}

#Preview {
    SkillArenaView(userProgress: UserProgress())
}
