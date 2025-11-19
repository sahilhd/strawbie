//
//  OnboardingFormsContainerView.swift
//  DAOmates
//
//  Container for onboarding forms after video
//

import SwiftUI

struct OnboardingFormsContainerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var currentStep = 1 // 1: TrialAgreement, 2: Name, 3: Email, 4: TOS, 5: Birthday, 6: Notifications
    @State private var userName = ""
    @State private var email = ""
    @State private var hasAgreedToTrial = false
    
    var body: some View {
        ZStack {
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
            
            VStack {
                // Step indicator
                HStack {
                    Text("Step \(currentStep) of 5")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Forms
                switch currentStep {
                case 1:
                    TrialAgreementStepView(
                        hasAgreed: $hasAgreedToTrial,
                        onContinue: {
                            withAnimation {
                                currentStep = 2
                            }
                        }
                    )
                
                case 2:
                    NameCreationStepView(
                        userName: $userName,
                        onContinue: {
                            withAnimation {
                                currentStep = 3
                            }
                        },
                        onBack: {
                            withAnimation {
                                currentStep = 1
                            }
                        }
                    )
                
                case 3:
                    EmailPasswordStepView(
                        userName: userName,
                        email: $email,
                        onContinue: {
                            withAnimation {
                                currentStep = 4
                            }
                        },
                        onBack: {
                            withAnimation {
                                currentStep = 2
                            }
                        }
                    )
                
                case 4:
                    TOSStepView(
                        email: email,
                        onContinue: {
                            withAnimation {
                                currentStep = 5
                            }
                        },
                        onBack: {
                            withAnimation {
                                currentStep = 3
                            }
                        }
                    )
                
                case 5:
                    BirthdayStepView(
                        userName: userName,
                        email: email,
                        onContinue: {
                            withAnimation {
                                currentStep = 6
                            }
                        },
                        onBack: {
                            withAnimation {
                                currentStep = 4
                            }
                        }
                    )
                
                case 6:
                    NotificationsStepView(
                        userName: userName,
                        email: email,
                        onComplete: {
                            authViewModel.isAuthenticated = true
                            authViewModel.showOnboarding = false
                            dismiss()
                        },
                        onBack: {
                            withAnimation {
                                currentStep = 5
                            }
                        }
                    )
                
                default:
                    Text("Unknown step")
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Step Views

struct TrialAgreementStepView: View {
    @Binding var hasAgreed: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("🍓")
                        .font(.system(size: 48))
                    
                    Text("Free 3-Day Trial")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("No credit card required")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Full access to all features")
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Cancel anytime")
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No hidden charges")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            Button(action: { hasAgreed.toggle() }) {
                HStack(spacing: 12) {
                    Image(systemName: hasAgreed ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundColor(hasAgreed ? .pink : .white.opacity(0.5))
                    
                    Text("I agree to the 3-day free trial")
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.pink)
                    .cornerRadius(12)
            }
            .disabled(!hasAgreed)
            .opacity(hasAgreed ? 1 : 0.5)
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .padding(.top, 24)
    }
}

struct NameCreationStepView: View {
    @Binding var userName: String
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var canContinue: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What's your name?")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                TextField("Enter your name...", text: $userName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.08))
                            .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .padding(.top, 24)
    }
}

struct EmailPasswordStepView: View {
    let userName: String
    @Binding var email: String
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var canContinue: Bool {
        !email.isEmpty && password.count >= 8 && password == confirmPassword
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Nice to meet you, \(userName)!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            
            ScrollView {
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .font(.system(size: 16))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
    }
}

// Simplified TOS Step
struct TOSStepView: View {
    let email: String
    @State private var agreeToTOS = false
    @State private var agreeToPrivacy = false
    @State private var showTOS = false
    @State private var showPrivacy = false
    
    let onContinue: () -> Void
    let onBack: () -> Void
    
    var canContinue: Bool {
        agreeToTOS && agreeToPrivacy
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Terms & Privacy")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            ScrollView {
                VStack(spacing: 12) {
                    Button(action: { withAnimation { showTOS.toggle() } }) {
                        HStack {
                            Text("Terms of Service")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: showTOS ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                    
                    if showTOS {
                        Text("Terms content here...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 14)
                    }
                    
                    Button(action: { withAnimation { showPrivacy.toggle() } }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: showPrivacy ? "chevron.up" : "chevron.down")
                                .foregroundColor(.pink)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                    
                    if showPrivacy {
                        Text("Privacy content here...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 14)
                    }
                    
                    Button(action: { agreeToTOS.toggle() }) {
                        HStack(spacing: 12) {
                            Image(systemName: agreeToTOS ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTOS ? .pink : .white.opacity(0.5))
                            Text("I agree to Terms")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Button(action: { agreeToPrivacy.toggle() }) {
                        HStack(spacing: 12) {
                            Image(systemName: agreeToPrivacy ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToPrivacy ? .pink : .white.opacity(0.5))
                            Text("I agree to Privacy Policy")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.horizontal, 16)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
    }
}

// Birthday Step
struct BirthdayStepView: View {
    let userName: String
    let email: String
    @State private var selectedYear = 2000
    
    let onContinue: () -> Void
    let onBack: () -> Void
    
    // Generate years from 1940 to current year
    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1940...currentYear).reversed())
    }
    
    var canContinue: Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - selectedYear
        return age >= 13
    }
    
    var ageCategory: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - selectedYear
        if age >= 18 {
            return "18+"
        } else if age >= 13 {
            return "13+"
        } else {
            return "Under 13"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Confirm your age to continue")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Select when you were born")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            .padding(.top, 40)
            
            // Wheel Picker
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 250)
                
                // Selection indicator
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 50)
                
                // Picker
                Picker("Birth Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.white)
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 250)
                .compositingGroup()
                .clipped()
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.pink)
                        .cornerRadius(12)
                }
                .disabled(!canContinue)
                .opacity(canContinue ? 1 : 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
    }
}

// Notifications Step
struct NotificationsStepView: View {
    let userName: String
    let email: String
    @State private var emailNotifications = true
    @State private var appNotifications = true
    @State private var isCreating = false
    
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Notification Preferences")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("Email Notifications")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $emailNotifications)
                            .labelsHidden()
                            .tint(.pink)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Text("App Notifications")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $appNotifications)
                            .labelsHidden()
                            .tint(.pink)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    isCreating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onComplete()
                    }
                }) {
                    if isCreating {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.black)
                            Text("Creating...")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.pink)
                        .cornerRadius(12)
                    } else {
                        Text("Start Chatting! 🍓")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.pink)
                            .cornerRadius(12)
                    }
                }
                .disabled(isCreating)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    OnboardingFormsContainerView()
        .environmentObject(AuthViewModel())
}

