import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.7
    @State private var isAnimating = false
    @State private var hasAcceptedDisclaimer = UserDefaults.standard.bool(forKey: "hasAcceptedDisclaimer")
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        if isActive {
            if !hasAcceptedDisclaimer {
                DisclaimerView(hasAcceptedDisclaimer: $hasAcceptedDisclaimer)
            } else if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                MainTabView()
            }
        } else {
            ZStack {
                Color(hex: "53A9E7")
                    .ignoresSafeArea()
                
                Image("Splash-Screen")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .modifier(PulseAnimation(isAnimating: isAnimating))
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.0)) {
                    opacity = 1.0
                    scale = 1.0
                }
                
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

struct PulseAnimation: ViewModifier {
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.05 : 1.0)
    }
}

#Preview {
    SplashScreenView()
} 