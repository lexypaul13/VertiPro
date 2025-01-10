import SwiftUI

struct ExerciseInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection = 0
    
    private let sections = [
        InstructionSection(
            title: "What is VertiPro?",
            content: [
                InstructionItem(
                    title: "Medical Exercise Made Fun",
                    description: "VertiPro is a gamified version of the gaze stabilization exercise, a proven technique in vestibular rehabilitation.",
                    icon: "gamecontroller.fill"
                ),
                InstructionItem(
                    title: "Scientific Background",
                    description: "This exercise helps improve your brain's ability to maintain clear vision while moving your head, essential for balance and daily activities.",
                    icon: "brain.head.profile"
                )
            ]
        ),
        InstructionSection(
            title: "How to Exercise",
            content: [
                InstructionItem(
                    title: "Keep Eyes Center",
                    description: "Keep your eyes fixed on the center point throughout the exercise. This is your visual anchor.",
                    icon: "eye.fill"
                ),
                InstructionItem(
                    title: "Follow the Blue Dot",
                    description: "Move your head to follow the blue dot while keeping your eyes fixed on the center. The dot shows where to move your head.",
                    icon: "circle.fill"
                ),
                InstructionItem(
                    title: "Smooth Movements",
                    description: "Use smooth, controlled head movements rather than quick, jerky motions. This helps train your vestibular system effectively.",
                    icon: "waveform.path"
                )
            ]
        ),
        InstructionSection(
            title: "Understanding Metrics",
            content: [
                InstructionItem(
                    title: "Accuracy Score",
                    description: "Shows how well you maintained focus on the target while moving your head. Higher scores indicate better gaze stability.",
                    icon: "percent"
                ),
                InstructionItem(
                    title: "Movement Speed",
                    description: "Tracks your head movement speed. Start slow and gradually increase as you improve.",
                    icon: "speedometer"
                ),
                InstructionItem(
                    title: "Dizziness Level",
                    description: "Rate your dizziness before and after exercises to track improvement over time.",
                    icon: "waveform.path.ecg"
                )
            ]
        ),
        InstructionSection(
            title: "Tips for Success",
            content: [
                InstructionItem(
                    title: "Proper Position",
                    description: "Sit comfortably with good posture. Keep your shoulders relaxed and back straight.",
                    icon: "figure.seated"
                ),
                InstructionItem(
                    title: "Regular Practice",
                    description: "Consistent practice is key. Start with shorter sessions and gradually increase duration.",
                    icon: "clock.arrow.circlepath"
                ),
                InstructionItem(
                    title: "Listen to Your Body",
                    description: "Take breaks if needed. Stop if you experience severe dizziness or discomfort.",
                    icon: "heart.text.square"
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Section Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<sections.count, id: \.self) { index in
                                Button(action: { selectedSection = index }) {
                                    VStack(spacing: 8) {
                                        Text(sections[index].title)
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(selectedSection == index ? .bold : .regular)
                                            .foregroundColor(selectedSection == index ? .blue : .secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedSection == index ? Color.blue.opacity(0.1) : Color.clear)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Content
                    VStack(spacing: 20) {
                        ForEach(sections[selectedSection].content) { item in
                            InstructionCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Exercise Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionSection {
    let title: String
    let content: [InstructionItem]
}

struct InstructionItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct InstructionCard: View {
    let item: InstructionItem
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ExerciseInstructionsView()
} 