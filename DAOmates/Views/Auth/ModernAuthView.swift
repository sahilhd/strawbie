//
//  ModernAuthView.swift
//  DAOmates
//
//  Premium authentication experience
//

import SwiftUI

struct ModernAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var showPassword = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)
                    
                    // ABG Branding
                    VStack(spacing: 16) {
                        // ABG Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)
                            
                            if let uiImage = UIImage(named: "abg_avatar") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.pink, .purple, .cyan],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: .pink.opacity(0.5), radius: 20, x: 0, y: 10)
                            } else {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                            }
                        }
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)
                        
                        VStack(spacing: 8) {
                            Text("Meet ABG")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .pink.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Your fashion-forward crypto bestie ✨")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, 50)
                    
                    // Auth Card
                    VStack(spacing: 24) {
                        // Toggle Sign In / Sign Up
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    isSignUp = false
                                }
                            }) {
                                Text("Sign In")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSignUp ? .white.opacity(0.5) : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    isSignUp = true
                                }
                            }) {
                                Text("Sign Up")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSignUp ? .white : .white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: geometry.size.width / 2)
                                    .offset(x: isSignUp ? geometry.size.width / 2 : 0)
                                    .animation(.spring(response: 0.3), value: isSignUp)
                            }
                        )
                        .background(Color.white.opacity(0.05))
                        .clipShape(Capsule())
                        
                        // Input Fields
                        VStack(spacing: 16) {
                            if isSignUp {
                                ModernTextField(
                                    icon: "person.fill",
                                    placeholder: "Username",
                                    text: $username
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            ModernTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            ModernTextField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                isSecure: !showPassword,
                                showPasswordToggle: true,
                                showPassword: $showPassword
                            )
                        }
                        
                        // Error/Success Messages
                        if let error = authViewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Action Button
                        Button(action: {
                            Task {
                                if isSignUp {
                                    await authViewModel.signUp(
                                        username: username,
                                        email: email,
                                        password: password,
                                        confirmPassword: password
                                    )
                                } else {
                                    await authViewModel.signIn(email: email, password: password)
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.white, .pink.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .white.opacity(0.3), radius: 20, x: 0, y: 10)
                        }
                        .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty || (isSignUp && username.isEmpty))
                        
                        // Biometric Sign In (if available and not signing up)
                        if !isSignUp, authViewModel.biometricAuthEnabled,
                           BiometricAuthService.shared.getBiometricType() != .none {
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                            
                            Button(action: {
                                Task {
                                    await authViewModel.signInWithBiometric()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: BiometricAuthService.shared.getBiometricType() == .faceID ? "faceid" : "touchid")
                                        .font(.title3)
                                    
                                    Text("Use \(BiometricAuthService.shared.getBiometricType() == .faceID ? "Face ID" : "Touch ID")")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 20)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 60)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.05, blue: 0.15),
                Color(red: 0.2, green: 0.1, blue: 0.25),
                Color(red: 0.15, green: 0.05, blue: 0.2)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Modern Text Field
struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var showPasswordToggle: Bool = false
    @Binding var showPassword: Bool
    
    init(icon: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, isSecure: Bool = false, showPasswordToggle: Bool = false, showPassword: Binding<Bool> = .constant(false)) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.showPasswordToggle = showPasswordToggle
        self._showPassword = showPassword
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.body)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.body)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
            }
            
            if showPasswordToggle {
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ModernAuthView()
        .environmentObject(AuthViewModel())
}

