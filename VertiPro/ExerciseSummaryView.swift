import SwiftUI

struct ExerciseSummaryView: View {
    @ObservedObject var dataStore = ExerciseDataStore.shared
    @State private var sortOption = SortOption.date
    @State private var showingFilters = false
    
    enum SortOption {
        case date
        case accuracy
        case duration
        case dizziness
        
        var description: String {
            switch self {
            case .date: return "Date"
            case .accuracy: return "Accuracy"
            case .duration: return "Duration"
            case .dizziness: return "Dizziness Level"
            }
        }
    }
    
    var sortedSessions: [ExerciseSession] {
        dataStore.sessions.sorted { first, second in
            switch sortOption {
            case .date:
                return first.date > second.date
            case .accuracy:
                return first.accuracy > second.accuracy
            case .duration:
                return first.duration > second.duration
            case .dizziness:
                return first.dizzinessLevel < second.dizzinessLevel
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if sortedSessions.isEmpty {
                    ContentUnavailableView(
                        "No Exercises Yet",
                        systemImage: "figure.walk",
                        description: Text("Complete your first exercise to see your progress here.")
                    )
                } else {
                    ForEach(sortedSessions) { session in
                        ExerciseSummaryRow(session: session)
                    }
                }
            }
            .navigationTitle("Exercise History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            Label("Date", systemImage: "calendar").tag(SortOption.date)
                            Label("Accuracy", systemImage: "percent").tag(SortOption.accuracy)
                            Label("Duration", systemImage: "clock").tag(SortOption.duration)
                            Label("Dizziness", systemImage: "waveform.path").tag(SortOption.dizziness)
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

struct ExerciseSummaryRow: View {
    let session: ExerciseSession
    
    var body: some View {
        NavigationLink(destination: ExerciseDetailView(session: session)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                    Spacer()
                    AccuracyBadge(accuracy: session.accuracy)
                }
                
                HStack(spacing: 16) {
                    StatisticView(
                        icon: "clock",
                        value: formatDuration(session.duration),
                        label: "Duration"
                    )
                    
                    StatisticView(
                        icon: "figure.walk",
                        value: String(format: "%.1f", session.headTurnsPerMinute),
                        label: "Turns/min"
                    )
                    
                    StatisticView(
                        icon: "waveform.path",
                        value: String(format: "%.1f", session.dizzinessLevel),
                        label: "Dizziness"
                    )
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }
}

struct StatisticView: View {
    let icon: String
    let value: String
    let label: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if icon == "waveform.path" {
                    Image("Dizzy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
                } else if icon == "figure.walk" {
                    Image("Four Way Direction")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
                } else {
                    Image(systemName: icon)
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
                }
                Text(value)
                    .bold()
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct AccuracyBadge: View {
    let accuracy: Double
    
    var color: Color {
        switch accuracy {
        case 80...100: return .green
        case 60..<80: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        Text("\(Int(accuracy))%")
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    ExerciseSummaryView()
}
