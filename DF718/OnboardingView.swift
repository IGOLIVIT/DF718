//
//  OnboardingView.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var userProgress: UserProgress
    @State private var currentStep = 0
    @State private var showContent = false
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = 0
    @State private var textOpacity: Double = 0
    
    let onboardingSteps = [
        OnboardingStep(
            icon: "brain.head.profile",
            title: "Train Your Mind",
            description: "Enhance your cognitive abilities through engaging challenges and interactive lessons."
        ),
        OnboardingStep(
            icon: "gamecontroller.fill",
            title: "Play & Learn",
            description: "Combine entertainment with education in beautifully designed mini-games."
        ),
        OnboardingStep(
            icon: "star.fill",
            title: "Collect Energy Orbs",
            description: "Earn rewards as you progress and unlock new levels of mental agility."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                // Animated background particles
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(AppColors.secondaryAccent.opacity(0.1))
                        .frame(width: CGFloat.random(in: 20...40))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: showContent
                        )
                        .scaleEffect(showContent ? 1.2 : 0.8)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Main icon with animation
                    Image(systemName: onboardingSteps[currentStep].icon)
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(AppColors.primaryAccent)
                        .scaleEffect(iconScale)
                        .rotationEffect(.degrees(iconRotation))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: iconScale)
                        .animation(.easeInOut(duration: 2), value: iconRotation)
                    
                    VStack(spacing: 20) {
                        // Title
                        Text(onboardingSteps[currentStep].title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)
                            .animation(.easeInOut(duration: 0.6).delay(0.2), value: textOpacity)
                        
                        // Description
                        Text(onboardingSteps[currentStep].description)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(textOpacity)
                            .animation(.easeInOut(duration: 0.6).delay(0.4), value: textOpacity)
                    }
                    
                    Spacer()
                    
                    // Progress indicators
                    HStack(spacing: 12) {
                        ForEach(0..<onboardingSteps.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentStep ? AppColors.secondaryAccent : AppColors.textSecondary.opacity(0.3))
                                .frame(width: 12, height: 12)
                                .scaleEffect(index == currentStep ? 1.2 : 1.0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStep)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Action button
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            if currentStep < onboardingSteps.count - 1 {
                                nextStep()
                            } else {
                                completeOnboarding()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Text(currentStep < onboardingSteps.count - 1 ? "Continue" : "Get Started")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: currentStep < onboardingSteps.count - 1 ? "arrow.right" : "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(AppColors.primaryAccent)
                                .shadow(color: AppColors.primaryAccent.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.6), value: showContent)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
            showContent = true
            iconScale = 1.0
            textOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(1.0)) {
            iconRotation = 5
        }
    }
    
    private func nextStep() {
        // Animate out
        withAnimation(.easeInOut(duration: 0.3)) {
            textOpacity = 0
            iconScale = 0.5
        }
        
        // Change content and animate in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentStep += 1
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                iconScale = 1.0
                textOpacity = 1.0
            }
        }
    }
    
    private func completeOnboarding() {
        userProgress.hasCompletedOnboarding = true
        userProgress.saveProgress()
    }
}

struct OnboardingStep {
    let icon: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView(userProgress: UserProgress())
}

