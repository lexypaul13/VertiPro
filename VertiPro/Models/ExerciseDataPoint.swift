import Foundation

struct ExerciseDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let averageAccuracy: Double
} 