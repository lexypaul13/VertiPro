//
//  AuthViewModel.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import Foundation
// AuthViewModel.swift
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        // Check authentication status (e.g., token existence)
        isAuthenticated = checkAuthenticationStatus()
    }

    func checkAuthenticationStatus() -> Bool {
        // Implement your authentication logic here
        // For now, we'll return false to simulate a logged-out state
        return false
    }
}
