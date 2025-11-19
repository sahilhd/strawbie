//
//  SignUpView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var walletAddress = ""
    
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
                ForEach(0..<15, id: \.self) { _ in
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: .random(in: 15...40))
                        .position(
                            x: .random(in: 0...geometry.size.width),
                            y: .random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: .random(in: 4...10))
                                .repeatForever(autoreverses: true),
                            value: UUID()
                        )
                }
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            HStack {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Text("Join DAOmates")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Connect with crypto legends")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Sign Up Form
                        VStack(spacing: 20) {
                            CustomTextField(
                                placeholder: "Username",
                                text: $username,
                                icon: "person.fill"
                            )
                            
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
                            
                            CustomTextField(
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            CustomTextField(
                                placeholder: "Wallet Address (Optional)",
                                text: $walletAddress,
                                icon: "bitcoinsign.circle.fill"
                            )
                            .autocapitalization(.none)
                            
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
                            
                            // Terms and Privacy
                            VStack(spacing: 8) {
                                Text("By signing up, you agree to our")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                HStack(spacing: 4) {
                                    Button(action: {
                                        // Show Terms of Service
                                    }) {
                                        Text("Terms of Service")
                                            .font(.caption2)
                                            .foregroundColor(.cyan)
                                            .underline()
                                    }
                                    
                                    Text("and")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Button(action: {
                                        // Show Privacy Policy
                                    }) {
                                        Text("Privacy Policy")
                                            .font(.caption2)
                                            .foregroundColor(.cyan)
                                            .underline()
                                    }
                                }
                            }
                            
                            Button(action: {
                                Task {
                                    await authViewModel.signUp(
                                        username: username,
                                        email: email,
                                        password: password,
                                        confirmPassword: confirmPassword,
                                        walletAddress: walletAddress.isEmpty ? nil : walletAddress
                                    )
                                    
                                    if authViewModel.isAuthenticated {
                                        dismiss()
                                    }
                                }
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Create Account")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            .disabled(authViewModel.isLoading)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
