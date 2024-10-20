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

    var body: some View {
        NavigationView {
            Form {
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

                // Privacy Section
//                Section(header: Text("Privacy")) {
//                    NavigationLink(destination: PrivacyPolicyView()) {
//                        Text("Privacy Policy")
//                    }
//                    Button(action: {
//                        // Handle data export
//                    }) {
//                        Text("Export Data")
//                    }
//                    Button(action: {
//                        // Handle data deletion
//                    }) {
//                        Text("Delete Data")
//                            .foregroundColor(.red)
//                    }
//                }

                // About Section
                Section(header: Text("About")) {
//                    NavigationLink(destination: OnboardingView()) {
//                        Text("App Tutorial")
//                    }
                    Button(action: {
                        // Share progress with healthcare provider
                    }) {
                        Text("Share Progress")
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .environment(\.sizeCategory, fontSizeCategory)
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
