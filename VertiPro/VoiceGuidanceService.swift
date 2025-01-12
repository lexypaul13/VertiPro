import AVFoundation

class VoiceGuidanceService {
    static let shared = VoiceGuidanceService()
    private let synthesizer = AVSpeechSynthesizer()
    private var lastSpokenTime: Date = Date()
    private let minimumInterval: TimeInterval = 0.5 // Reduced from 2.0 to 0.5 seconds
    
    private init() {}
    
    func speakDirection(_ direction: Direction) {
        // Cancel any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Check if enough time has passed since last speech
        guard Date().timeIntervalSince(lastSpokenTime) >= minimumInterval else { return }
        
        let text: String
        switch direction {
        case .left:
            text = "Turn head left"
        case .right:
            text = "Turn head right"
        case .up:
            text = "Turn head up"
        case .down:
            text = "Turn head down"
        }
        
        speak(text)
        lastSpokenTime = Date()
    }
    
    func speakFeedback(_ feedback: String) {
        guard Date().timeIntervalSince(lastSpokenTime) >= minimumInterval else { return }
        speak(feedback)
        lastSpokenTime = Date()
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45  // Slightly slower for better clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
    }
} 