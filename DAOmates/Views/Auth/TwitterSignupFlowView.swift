//
//  TwitterSignupFlowView.swift
//  DAOmates
//
//  A clean, Twitter-style multi-step signup flow.
//

import SwiftUI

struct TwitterSignupFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var step: SignupStep = .welcome
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var agreeTerms: Bool = false
    @State private var enableBiometric: Bool = true
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        ZStack {
            // Subtle dark background
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.06, blue: 0.12),
                    Color(red: 0.09, green: 0.07, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with back/close
                HStack {
                    if step != .welcome {
                        Button(action: { withAnimation { step = step.previous() } }) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.08)))
                        }
                    } else {
                        Color.clear.frame(width: 36, height: 36)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                
                Spacer(minLength: 0)
                
                // Content
                VStack(spacing: 28) {
                    switch step {
                    case .welcome:
                        WelcomeStepView(onContinue: { withAnimation { step = .email } })
                    case .email:
                        FormStepView(
                            title: "Create your account",
                            subtitle: "Enter your email",
                            content: {
                                ModernField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                            },
                            isContinueEnabled: isValidEmail(email)
                        ) { withAnimation { step = .username } }
                    case .username:
                        FormStepView(
                            title: "Choose your name",
                            subtitle: "What should Strawbie call you?",
                            content: {
                                ModernField(icon: "person.fill", placeholder: "Username", text: $username)
                            },
                            isContinueEnabled: username.trimmingCharacters(in: .whitespaces).count >= 2
                        ) { withAnimation { step = .password } }
                    case .password:
                        FormStepView(
                            title: "Secure your account",
                            subtitle: "Create a password",
                            content: {
                                ModernField(icon: "lock.fill", placeholder: "Password", text: $password, secure: true)
                            },
                            isContinueEnabled: password.count >= 8
                        ) { withAnimation { step = .terms } }
                    case .terms:
                        TermsStepView(agree: $agreeTerms, showTerms: $showTerms, showPrivacy: $showPrivacy) {
                            withAnimation { step = .biometric }
                        }
                        .sheet(isPresented: $showTerms) { TermsOfServiceView() }
                        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
                    case .biometric:
                        BiometricStepView(enableBiometric: $enableBiometric) {
                            Task {
                                if enableBiometric { authViewModel.biometricAuthEnabled = true }
                                await authViewModel.signUp(
                                    username: username,
                                    email: email,
                                    password: password,
                                    confirmPassword: password
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 0)
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Steps
private enum SignupStep { case welcome, email, username, password, terms, biometric
    func previous() -> SignupStep {
        switch self {
        case .welcome: return .welcome
        case .email: return .welcome
        case .username: return .email
        case .password: return .username
        case .terms: return .password
        case .biometric: return .terms
        }
    }
}

// MARK: - Reusable Subviews
private struct WelcomeStepView: View {
    let onContinue: () -> Void
    @State private var animate = false
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(0.6)
                Image("strawbie_icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
            }
            .scaleEffect(animate ? 1.0 : 0.85)
            .onAppear { withAnimation(.spring(response: 0.6).delay(0.1)) { animate = true } }
            
            Text("Meet Strawbie")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("Your AI bestie who vibes with you")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: onContinue) {
                Text("Create account")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(Color.white)
                    )
            }
        }
    }
}

private struct FormStepView<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content
    let isContinueEnabled: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            content
            
            if isContinueEnabled {
                Button(action: onContinue) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white))
                }
            } else {
                Capsule().fill(Color.white.opacity(0.2)).frame(height: 50)
                    .overlay(Text("Next").foregroundColor(.white.opacity(0.6)).font(.headline))
            }
        }
    }
}

private struct TermsStepView: View {
    @Binding var agree: Bool
    @Binding var showTerms: Bool
    @Binding var showPrivacy: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Review our terms")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                Text("Please agree to continue")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle(isOn: $agree) {
                HStack(spacing: 8) {
                    Text("I agree to the")
                        .foregroundColor(.white.opacity(0.8))
                    Button("Terms of Service") { showTerms = true }
                    Text("and")
                        .foregroundColor(.white.opacity(0.8))
                    Button("Privacy Policy") { showPrivacy = true }
                }
                .font(.footnote)
            }
            .tint(.pink)
            .foregroundColor(.white)
            
            if agree {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.white))
                }
            } else {
                Capsule().fill(Color.white.opacity(0.2)).frame(height: 50)
                    .overlay(Text("Continue").foregroundColor(.white.opacity(0.6)).font(.headline))
            }
        }
    }
}

private struct BiometricStepView: View {
    @Binding var enableBiometric: Bool
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Secure your account")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                Text("Enable Face ID / Touch ID for quick sign in")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Toggle(isOn: $enableBiometric) {
                HStack(spacing: 8) {
                    Image(systemName: "faceid")
                    Text("Enable Biometric Sign In")
                }
                .foregroundColor(.white)
            }
            .tint(.pink)
            
            Button(action: onFinish) {
                Text("Finish")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.white))
            }
        }
    }
}

// MARK: - Utility Field
private struct ModernField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var secure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 22)
            if secure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                    .keyboardType(keyboard)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
    }
}

#Preview {
    TwitterSignupFlowView().environmentObject(AuthViewModel())
}


