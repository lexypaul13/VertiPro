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
                    Image(systemName: "chart.bar")
                    Text("Dashboard")
                }
                .tag(0)
            
            DailyLogView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Daily Log")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .toolbar(.hidden, for: .tabBar)  // This will hide the tab bar when needed
    }
}

#Preview {
    MainTabView()
}
