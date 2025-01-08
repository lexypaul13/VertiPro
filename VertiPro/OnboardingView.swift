import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let color: Color
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var selectedPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Your Progress",
            description: "Monitor your vestibular rehabilitation journey with detailed metrics and performance tracking",
            systemImage: "chart.xyaxis.line",
            color: .blue
        ),
        OnboardingPage(
            title: "Guided Exercises",
            description: "Follow precise head movement exercises with real-time feedback and accuracy tracking",
            systemImage: "figure.mixed.cardio",
            color: .green
        ),
        OnboardingPage(
            title: "Monitor Dizziness",
            description: "Keep track of your dizziness levels and see how they improve over time",
            systemImage: "waveform.path.ecg.rectangle",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $selectedPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(pages[index].color.opacity(0.1))
                                    .frame(width: 200, height: 200)
                                
                                Image(systemName: pages[index].systemImage)
                                    .font(.system(size: 70, weight: .medium))
                                    .foregroundColor(pages[index].color)
                            }
                            .padding(.bottom, 40)
                            
                            Text(pages[index].title)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].description)
                                .font(.system(.body, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page Control and Button
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == selectedPage ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: selectedPage)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Button {
                        if selectedPage < pages.count - 1 {
                            withAnimation {
                                selectedPage += 1
                            }
                        } else {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        Text(selectedPage < pages.count - 1 ? "Continue" : "Get Started")
                            .font(.system(.title3, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 