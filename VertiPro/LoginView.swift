//
//  LoginView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            Spacer()

            // Logo
            Image("VertiProLogo") // Add your logo image to Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding()

            // Input Fields
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            // Buttons
            HStack(spacing: 20) {
                Button(action: {
                    // Handle Login
                }) {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.primaryBlue)
                        .cornerRadius(10)
                }

                Button(action: {
                    // Handle Signup
                }) {
                    Text("Signup")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.primaryBlue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)

            Spacer()
        }
        .background(Color.primaryBlue.edgesIgnoringSafeArea(.all))
    }
}


#Preview {
    LoginView()
}
// Colors.swift

extension Color {
    static let primaryBlue = Color(red: 29/255, green: 161/255, blue: 242/255)
    static let backgroundWhite = Color.white
}
