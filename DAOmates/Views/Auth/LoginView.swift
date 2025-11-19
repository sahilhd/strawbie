//
//  LoginView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showBiometricPrompt = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Crypto-themed gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0.2, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated background elements
                ForEach(0..<20, id: \.self) { _ in
                    Circle()
                        .fill(Color.cyan.opacity(0.1))
                        .frame(width: .random(in: 20...60))
                        .position(
                            x: .random(in: 0...geometry.size.width),
                            y: .random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: .random(in: 3...8))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 60)
                        
                        // Logo and Title
                        VStack(spacing: 20) {
                            Image(systemName: "person.3.sequence.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.cyan, .purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("DAOmates")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Chat with Crypto Legends")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Login Form
                        VStack(spacing: 20) {
                            CustomTextField(
                                placeholder: "Email",
                                text: $email,
                                icon: "envelope.fill"
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            CustomTextField(
                                placeholder: "Password",
                                text: $password,
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            if let successMessage = authViewModel.successMessage {
                                Text(successMessage)
                                    .foregroundColor(.green)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            // Biometric Auth Button
                            if authViewModel.biometricAuthEnabled, 
                               BiometricAuthService.shared.getBiometricType() != .none {
                                Button(action: {
                                    Task {
                                        await authViewModel.signInWithBiometric()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: BiometricAuthService.shared.getBiometricType() == .faceID ? "faceid" : "touchid")
                                            .font(.title3)
                                        Text("Sign in with \(BiometricAuthService.shared.getBiometricType() == .faceID ? "Face ID" : "Touch ID")")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(
                                        LinearGradient(
                                            colors: [.green, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                                .disabled(authViewModel.isLoading)
                            }
                            
                            Button(action: {
                                Task {
                                    await authViewModel.signIn(email: email, password: password)
                                }
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            .disabled(authViewModel.isLoading)
                            
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .foregroundColor(.cyan.opacity(0.8))
                                    .font(.caption)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.vertical, 10)
                            
                            Button(action: {
                                showSignUp = true
                            }) {
                                Text("Don't have an account? Sign Up")
                                    .foregroundColor(.cyan)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .onChange(of: authViewModel.isAuthenticated) { oldValue, newValue in
            if newValue {
                authViewModel.clearMessages()
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    LoginView()
}
