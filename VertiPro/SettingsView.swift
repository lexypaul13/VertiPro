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
    @ObservedObject var dataStore = ExerciseDataStore.shared
    @State private var showingInstructions = false
    @State private var fontSizeCategory: ContentSizeCategory = .large
    @State private var notificationsEnabled = false
    @State private var notificationTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                // Accessibility Section
                Section(header: Text("Accessibility")) {
                    Picker("Font Size", selection: $fontSizeCategory) {
                        Text("Small").tag(ContentSizeCategory.small)
                        Text("Medium").tag(ContentSizeCategory.medium)
                        Text("Large").tag(ContentSizeCategory.large)
                        Text("Extra Large").tag(ContentSizeCategory.extraLarge)
                    }
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle("Enable Reminders", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                // Help Section
                Section(header: Text("Help")) {
                    Button(action: {
                        showingInstructions = true
                    }) {
                        Text("Exercise Instructions")
                    }
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
