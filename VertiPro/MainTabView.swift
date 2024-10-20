//
//  MainTabView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI

// MainTabView.swift
struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Dashboard")
                }

            DailyLogView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Daily Log")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView()
}
