import SwiftUI

struct CountdownView: View {
    let headMovement: String
    @Binding var isCountdownComplete: Bool
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var countdown = 3
    @State private var circleScale: CGFloat = 0.2
    @State private var circleOpacity: Double = 0
    @State private var textScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Close Button
            VStack {
                HStack {
                    Button(action: {
                        onDismiss()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 40) {
                // Title
                VStack(spacing: 12) {
                    Text("Gaze Stabilization Exercise")
                        .font(.title)
                        .fontWeight(.medium)
                    Text(headMovement)
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Countdown Animation
                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 150, height: 150)
                    
                    // Animated circle
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 150, height: 150)
                        .scaleEffect(circleScale)
                        .opacity(circleOpacity)
                    
                    // Countdown number
                    Text("\(countdown)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(textScale)
                }
                
                Spacer()
                
                // Get Ready Text
                Text("Get ready in")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            startCountdownAnimation()
        }
        .onDisappear {
            if !isCountdownComplete {
                onDismiss()
            }
        }
    }
    
    private func startCountdownAnimation() {
        // Initial animation state
        withAnimation(.easeOut(duration: 0.5)) {
            circleOpacity = 1
            circleScale = 1
        }
        
        // Start countdown timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                // Animate number change
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    textScale = 1.2
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                    textScale = 1.0
                }
                
                // Animate circle
                withAnimation(.easeOut(duration: 0.8)) {
                    circleScale = 0.2
                    circleOpacity = 0
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                    circleScale = 1
                    circleOpacity = 1
                }
                
                countdown -= 1
            } else {
                timer.invalidate()
                // Final animation before completion
                withAnimation(.easeOut(duration: 0.5)) {
                    circleOpacity = 0
                    textScale = 0.5
                }
                
                // Delay before starting exercise
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isCountdownComplete = true
                    dismiss()
                }
            }
        }
    }
}

// Preview
struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView(
            headMovement: "Left & Right",
            isCountdownComplete: .constant(false),
            onDismiss: {}
        )
    }
} 
