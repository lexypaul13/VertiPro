//
//  SettingsView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

// SettingsView.swift
import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var textSize: Double = 16 // Default text size
    @State private var hapticFeedbackEnabled = true
    @State private var showingInstructions = false
    @State private var showingClearDataAlert = false
    @StateObject private var dataStore = ExerciseDataStore.shared

    var body: some View {
        NavigationView {
            Form {
                // Exercise Instructions Section
                Section {
                    Button(action: { showingInstructions = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text("Exercise Instructions")
                        }
                    }
                } header: {
                    Text("Help")
                } footer: {
                    Text("Learn how to perform exercises effectively and understand your progress metrics.")
                }

                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Exercise Reminders")
                    }
                    .onChange(of: notificationsEnabled) { value in
                        if value {
                            scheduleExerciseReminder()
                        } else {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                    }
                }

                // Accessibility Section
                Section(header: Text("Accessibility")) {
                    // Text Size Slider
                    VStack(alignment: .leading) {
                        Text("Text Size: \(Int(textSize))")
                        Slider(value: $textSize, in: 12...24, step: 1)
                            .accessibilityValue("\(Int(textSize)) points")
                    }

                    // Haptic Feedback Toggle
                    Toggle(isOn: $hapticFeedbackEnabled) {
                        Text("Haptic Feedback")
                    }
                }

                // Data Management Section
                Section {
                    Button(role: .destructive, action: {
                        showingClearDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear All Data")
                        }
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("This will permanently delete all exercise data and reset the app to its initial state.")
                }

                // About Section
                Section(header: Text("About")) {
                    Button(action: {
                        // Share progress with healthcare provider
                    }) {
                        Text("Share Progress")
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .environment(\.sizeCategory, fontSizeCategory)
            .sheet(isPresented: $showingInstructions) {
                ExerciseInstructionsView()
            }
            .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear Data", role: .destructive) {
                    dataStore.clearAllData()
                }
            } message: {
                Text("This will permanently delete all your exercise data and reset the app. This action cannot be undone.")
            }
        }
    }

    // Helper to convert text size to DynamicTypeSize
    var fontSizeCategory: ContentSizeCategory {
        switch textSize {
        case 12...14:
            return .small
        case 15...17:
            return .medium
        case 18...20:
            return .large
        case 21...24:
            return .extraLarge
        default:
            return .medium
        }
    }

    // Function to schedule exercise reminders
    func scheduleExerciseReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time for your VertiPro exercise!"
        content.body = "Keep up with your daily exercises to improve your balance."
        content.sound = UNNotificationSound.default

        // Schedule the notification for a specific time (e.g., 9 AM daily)
        var dateComponents = DateComponents()
        dateComponents.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "exerciseReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
}
