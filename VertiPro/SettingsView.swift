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
                
                // Help Section
                Section(header: Text("Help")) {
                    Button(action: {
                        showingInstructions = true
                    }) {
                        Text("Exercise Instructions")
                    }
                }
                
                // Disclaimer Section
                Section(header: Text("Important Information")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Medical Disclaimer")
                            .font(.headline)
                        
                        Text("VertiPro is not a medical device and is not intended to diagnose, treat, cure, or prevent any disease or medical condition.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("This app is designed as a supplementary tool for vestibular rehabilitation exercises. Always consult with your healthcare provider before starting any exercise program.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("If you experience severe dizziness, nausea, or any concerning symptoms, stop using the app immediately and seek medical attention.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .environment(\.sizeCategory, fontSizeCategory)
            .sheet(isPresented: $showingInstructions) {
                ExerciseInstructionsView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
