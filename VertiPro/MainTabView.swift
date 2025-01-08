//
//  MainTabView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI

// MainTabView.swift
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                        .environment(\.symbolRenderingMode, .hierarchical)
                }
                .tag(0)
            
            DailyLogView()
                .tabItem {
                    Label("Daily Log", systemImage: "calendar")
                        .environment(\.symbolRenderingMode, .hierarchical)
                }
                .tag(1)
            
            ExerciseSummaryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet.clipboard.fill")
                        .environment(\.symbolRenderingMode, .hierarchical)
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                        .environment(\.symbolRenderingMode, .hierarchical)
                }
                .tag(3)
        }
        .tint(Color.blue)
    }
}

#Preview {
    MainTabView()
}
