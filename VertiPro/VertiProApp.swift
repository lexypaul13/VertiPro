//
//  VertiProApp.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI

@main
struct VertiProApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
