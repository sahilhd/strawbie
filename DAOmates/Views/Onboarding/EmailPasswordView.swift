//
//  EmailPasswordView.swift
//  DAOmates
//
//  Email and password creation after trial agreement
//

import SwiftUI

struct EmailPasswordView: View {
    @Environment(\.dismiss) var dismiss
    let userName: String
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var errorMessage = ""
    
    var canContinue: Bool {
        isValidEmail(email) && password.count >= 8 && password == confirmPassword
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.0, blue: 0.1),
                    Color(red: 0.15, green: 0.05, blue: 0.25),
                    Color(red: 0.05, green: 0.0, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                // Progress indicator
                VStack(spacing: 6) {
                    Text("Step 2 of 5")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.pink)
                                .frame(width: geo.size.width * 0.4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Welcome message
                        VStack(spacing: 8) {
                            Text("Nice to meet you, \(userName)! 👋")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Create your account to start chatting with Strawbie")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        
                        // Email field
                        VStack(spacing: 8) {
                            Text("Email")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("you@example.com", text: $email)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.none)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.08))
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                        
                        // Password field
                        VStack(spacing: 8) {
                            Text("Password")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                if showPassword {
                                    TextField("At least 8 characters", text: $password)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("At least 8 characters", text: $password)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                                    .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // Confirm password field
                        VStack(spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            SecureField("Confirm password", text: $confirmPassword)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.08))
                                        .stroke(
                                            password != confirmPassword && !confirmPassword.isEmpty ?
                                            Color.red.opacity(0.5) : Color.pink.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .padding(.horizontal, 16)
                        
                        // Password requirements
                        VStack(spacing: 6) {
                            PasswordRequirement(text: "At least 8 characters", isMet: password.count >= 8)
                            PasswordRequirement(text: "Passwords match", isMet: password == confirmPassword && !confirmPassword.isEmpty)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Continue button
                NavigationLink(
                    destination: ExpandableTOSView(userName: userName, email: email)
                        .navigationBarBackButtonHidden(true)
                ) {
                    Button(action: {}) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canContinue ? Color.pink : Color.white.opacity(0.3))
                            )
                    }
                    .disabled(!canContinue)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let regex = try? NSRegularExpression(pattern: emailPattern)
        return regex?.firstMatch(in: email, range: NSRange(email.startIndex..., in: email)) != nil
    }
}

struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isMet ? .green : .white.opacity(0.3))
            
            Text(text)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
        }
    }
}

#Preview {
    EmailPasswordView(userName: "Bestie")
}

