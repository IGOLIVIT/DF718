//
//  Models.swift
//  DF718
//
//  Created by IGOR on 13/10/2025.
//

import SwiftUI
import Foundation
import Combine

// MARK: - Color Theme
struct AppColors {
    static let background = Color(hex: "0B0C2A")
    static let primaryAccent = Color(hex: "FF3B6C")
    static let secondaryAccent = Color(hex: "FFD85A")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let cardBackground = Color.white.opacity(0.1)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - User Progress Model
class UserProgress: ObservableObject {
    @Published var energyOrbs: Int = 0
    @Published var currentLevel: Int = 1
    @Published var totalLessonsCompleted: Int = 0
    @Published var totalPlaytime: TimeInterval = 0
    @Published var completedModules: Set<String> = []
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadProgress()
    }
    
    func saveProgress() {
        userDefaults.set(energyOrbs, forKey: "energyOrbs")
        userDefaults.set(currentLevel, forKey: "currentLevel")
        userDefaults.set(totalLessonsCompleted, forKey: "totalLessonsCompleted")
        userDefaults.set(totalPlaytime, forKey: "totalPlaytime")
        userDefaults.set(Array(completedModules), forKey: "completedModules")
        userDefaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
    
    func loadProgress() {
        energyOrbs = userDefaults.integer(forKey: "energyOrbs")
        currentLevel = max(1, userDefaults.integer(forKey: "currentLevel"))
        totalLessonsCompleted = userDefaults.integer(forKey: "totalLessonsCompleted")
        totalPlaytime = userDefaults.double(forKey: "totalPlaytime")
        completedModules = Set(userDefaults.stringArray(forKey: "completedModules") ?? [])
        hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
    }
    
    func resetProgress() {
        energyOrbs = 0
        currentLevel = 1
        totalLessonsCompleted = 0
        totalPlaytime = 0
        completedModules.removeAll()
        hasCompletedOnboarding = true // Keep onboarding completed
        saveProgress()
    }
    
    func completeLesson() {
        energyOrbs += 1
        totalLessonsCompleted += 1
        
        // Level up every 5 lessons
        if totalLessonsCompleted % 5 == 0 {
            currentLevel += 1
        }
        
        saveProgress()
    }
    
    func completeModule(_ moduleId: String) {
        completedModules.insert(moduleId)
        completeLesson()
    }
    
    func addPlaytime(_ time: TimeInterval) {
        totalPlaytime += time
        saveProgress()
    }
    
    var levelProgress: Double {
        let lessonsInCurrentLevel = totalLessonsCompleted % 5
        return Double(lessonsInCurrentLevel) / 5.0
    }
    
    var formattedPlaytime: String {
        let hours = Int(totalPlaytime) / 3600
        let minutes = (Int(totalPlaytime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Skill Module Model
struct SkillModule: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let tasks: [SkillTask]
    let moduleId: String
}

struct SkillTask: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

// MARK: - Game Models
struct FallingObject: Identifiable {
    let id = UUID()
    var position: CGPoint
    let isCorrect: Bool
    let symbol: String
    let color: Color
}

// MARK: - Sample Data
extension SkillModule {
    static let sampleModules: [SkillModule] = [
        SkillModule(
            title: "Mind Boost",
            description: "Enhance your recall with pattern recognition",
            icon: "brain.head.profile",
            tasks: [
                SkillTask(
                    question: "Which sequence was shown? (Red, Blue, Green, Yellow)",
                    options: ["R-B-G-Y", "B-R-Y-G", "G-Y-R-B", "Y-G-B-R"],
                    correctAnswer: 0,
                    explanation: "Great! Pattern recognition improves working recall."
                ),
                SkillTask(
                    question: "How many items were in the last group?",
                    options: ["3", "5", "7", "9"],
                    correctAnswer: 1,
                    explanation: "Counting exercises strengthen numerical recall."
                ),
                SkillTask(
                    question: "What was the first word in the sequence?",
                    options: ["Apple", "Brain", "Cloud", "Dream"],
                    correctAnswer: 0,
                    explanation: "Word recall builds verbal processing pathways."
                )
            ],
            moduleId: "mind_boost"
        ),
        SkillModule(
            title: "Focus Sprint",
            description: "Train sustained attention and concentration",
            icon: "target",
            tasks: [
                SkillTask(
                    question: "Which shape appeared most frequently?",
                    options: ["Circle", "Square", "Triangle", "Diamond"],
                    correctAnswer: 2,
                    explanation: "Attention to detail improves focus accuracy."
                ),
                SkillTask(
                    question: "What color was the moving object?",
                    options: ["Red", "Blue", "Green", "Purple"],
                    correctAnswer: 1,
                    explanation: "Tracking moving objects enhances visual attention."
                ),
                SkillTask(
                    question: "How many times did the pattern change?",
                    options: ["2", "4", "6", "8"],
                    correctAnswer: 2,
                    explanation: "Pattern monitoring develops sustained focus."
                )
            ],
            moduleId: "focus_sprint"
        ),
        SkillModule(
            title: "Logic Flow",
            description: "Develop logical reasoning and problem-solving",
            icon: "puzzlepiece.extension",
            tasks: [
                SkillTask(
                    question: "If A > B and B > C, then:",
                    options: ["A < C", "A = C", "A > C", "Cannot determine"],
                    correctAnswer: 2,
                    explanation: "Transitive relationships are key to logical reasoning."
                ),
                SkillTask(
                    question: "What comes next in the sequence: 2, 4, 8, 16, ?",
                    options: ["24", "32", "48", "64"],
                    correctAnswer: 1,
                    explanation: "Pattern recognition strengthens logical thinking."
                ),
                SkillTask(
                    question: "If all roses are flowers and some flowers are red, then:",
                    options: ["All roses are red", "Some roses might be red", "No roses are red", "All flowers are roses"],
                    correctAnswer: 1,
                    explanation: "Logical deduction helps with complex reasoning."
                )
            ],
            moduleId: "logic_flow"
        ),
        SkillModule(
            title: "Speed Processing",
            description: "Improve reaction time and quick thinking",
            icon: "bolt.fill",
            tasks: [
                SkillTask(
                    question: "Quick! What's 15 + 27?",
                    options: ["40", "42", "44", "46"],
                    correctAnswer: 1,
                    explanation: "Mental math builds processing speed."
                ),
                SkillTask(
                    question: "Which word doesn't belong: Cat, Dog, Bird, Car?",
                    options: ["Cat", "Dog", "Bird", "Car"],
                    correctAnswer: 3,
                    explanation: "Rapid categorization improves cognitive flexibility."
                ),
                SkillTask(
                    question: "How many vowels in 'EDUCATION'?",
                    options: ["3", "4", "5", "6"],
                    correctAnswer: 2,
                    explanation: "Quick analysis tasks enhance processing efficiency."
                )
            ],
            moduleId: "speed_processing"
        ),
        SkillModule(
            title: "Creative Thinking",
            description: "Boost creativity and innovative problem-solving",
            icon: "lightbulb.fill",
            tasks: [
                SkillTask(
                    question: "How many uses can you think of for a paperclip?",
                    options: ["1-3 uses", "4-6 uses", "7-10 uses", "10+ uses"],
                    correctAnswer: 3,
                    explanation: "Creative thinking involves generating multiple solutions."
                ),
                SkillTask(
                    question: "What connects: Ocean, Desert, Library, Mind?",
                    options: ["Water", "Vastness", "Knowledge", "Silence"],
                    correctAnswer: 1,
                    explanation: "Abstract thinking finds unexpected connections."
                ),
                SkillTask(
                    question: "If you could redesign a chair, what would you change?",
                    options: ["Add wheels", "Make it foldable", "Add storage", "All of the above"],
                    correctAnswer: 3,
                    explanation: "Innovation combines multiple improvements."
                )
            ],
            moduleId: "creative_thinking"
        ),
        SkillModule(
            title: "Emotional Intelligence",
            description: "Develop empathy and social awareness",
            icon: "heart.fill",
            tasks: [
                SkillTask(
                    question: "Someone looks upset after a meeting. What should you do?",
                    options: ["Ignore it", "Ask if they're okay", "Tell them to cheer up", "Gossip about it"],
                    correctAnswer: 1,
                    explanation: "Empathy starts with genuine concern and active listening."
                ),
                SkillTask(
                    question: "How do you handle criticism?",
                    options: ["Get defensive", "Listen and learn", "Ignore it", "Argue back"],
                    correctAnswer: 1,
                    explanation: "Emotional maturity means learning from feedback."
                ),
                SkillTask(
                    question: "What helps build trust in relationships?",
                    options: ["Being right", "Consistency", "Being popular", "Avoiding conflict"],
                    correctAnswer: 1,
                    explanation: "Trust is built through reliable, consistent behavior."
                )
            ],
            moduleId: "emotional_intelligence"
        ),
        SkillModule(
            title: "Critical Analysis",
            description: "Sharpen analytical and evaluation skills",
            icon: "magnifyingglass",
            tasks: [
                SkillTask(
                    question: "What's the best way to evaluate news sources?",
                    options: ["Check popularity", "Verify sources", "Trust headlines", "Follow trends"],
                    correctAnswer: 1,
                    explanation: "Critical thinking requires source verification and fact-checking."
                ),
                SkillTask(
                    question: "When making decisions, what's most important?",
                    options: ["Speed", "Popularity", "Evidence", "Intuition"],
                    correctAnswer: 2,
                    explanation: "Good decisions are based on solid evidence and analysis."
                ),
                SkillTask(
                    question: "How do you spot bias in information?",
                    options: ["Check emotions", "Look for balance", "Question motives", "All of the above"],
                    correctAnswer: 3,
                    explanation: "Bias detection requires multiple analytical approaches."
                )
            ],
            moduleId: "critical_analysis"
        ),
        SkillModule(
            title: "Mindfulness & Focus",
            description: "Enhance present-moment awareness and concentration",
            icon: "leaf.fill",
            tasks: [
                SkillTask(
                    question: "What's the key to mindful breathing?",
                    options: ["Breathing fast", "Counting breaths", "Holding breath", "Breathing loudly"],
                    correctAnswer: 1,
                    explanation: "Mindful breathing involves focused attention on the breath cycle."
                ),
                SkillTask(
                    question: "How do you handle distracting thoughts during focus time?",
                    options: ["Fight them", "Acknowledge and return", "Ignore completely", "Follow them"],
                    correctAnswer: 1,
                    explanation: "Mindfulness teaches gentle acknowledgment without judgment."
                ),
                SkillTask(
                    question: "What improves concentration the most?",
                    options: ["Multitasking", "Single-tasking", "Background noise", "Constant stimulation"],
                    correctAnswer: 1,
                    explanation: "Deep focus comes from dedicated attention to one task."
                )
            ],
            moduleId: "mindfulness_focus"
        )
    ]
}
