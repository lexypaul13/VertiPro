import Foundation

class DirectionSequence {
    enum Pattern {
        case vertical      // Up-Down
        case horizontal   // Left-Right
        case combined     // All directions
    }
    
    private var currentSequence: [Direction] = []
    private var currentIndex: Int = 0
    private let pattern: Pattern
    private let speed: Double
    
    init(headMovement: String, speed: Double) {
        // Convert headMovement string to pattern
        switch headMovement {
        case "Up & Down":
            self.pattern = .vertical
        case "Left & Right":
            self.pattern = .horizontal
        default:
            self.pattern = .combined
        }
        self.speed = speed
        generateSequence()
    }
    
    private func generateSequence() {
        switch pattern {
        case .vertical:
            // Simple Up-Down pattern
            currentSequence = [.up, .down, .up, .down]
        case .horizontal:
            // Simple Left-Right pattern
            currentSequence = [.left, .right, .left, .right]
        case .combined:
            // Simple clockwise pattern
            currentSequence = [.up, .right, .down, .left]
        }
    }
    
    func getNextDirection() -> Direction {
        let direction = currentSequence[currentIndex]
        currentIndex = (currentIndex + 1) % currentSequence.count
        return direction
    }
    
    var directionDuration: TimeInterval {
        switch speed {
        case 0: return 3.0     // Extra Slow
        case 1: return 2.0     // Slow
        case 2: return 1.5     // Normal
        case 3: return 1.0     // Fast
        case 4: return 0.5     // Extra Fast
        default: return 1.5
        }
    }
} 