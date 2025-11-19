//
//  ExpandableTOSView.swift
//  DAOmates
//
//  Expandable Terms of Service and Privacy Policy
//

import SwiftUI

struct ExpandableTOSView: View {
    @Environment(\.dismiss) var dismiss
    let userName: String
    let email: String
    
    @State private var showTOS = false
    @State private var showPrivacy = false
    @State private var agreeToTOS = false
    @State private var agreeToPrivacy = false
    
    var canContinue: Bool {
        agreeToTOS && agreeToPrivacy
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
                    Text("Terms & Privacy")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                // Progress indicator
                VStack(spacing: 6) {
                    Text("Step 3 of 5")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.pink)
                                .frame(width: geo.size.width * 0.6)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // TOS Section
                        VStack(spacing: 0) {
                            Button(action: { withAnimation(.spring()) { showTOS.toggle() } }) {
                                HStack {
                                    Text("Terms of Service")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showTOS ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.pink)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                            }
                            
                            if showTOS {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ScrollView {
                                    Text(tosText)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineSpacing(4)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                }
                                .frame(maxHeight: 150)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Privacy Section
                        VStack(spacing: 0) {
                            Button(action: { withAnimation(.spring()) { showPrivacy.toggle() } }) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: showPrivacy ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.pink)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                            }
                            
                            if showPrivacy {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                ScrollView {
                                    Text(privacyText)
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineSpacing(4)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                }
                                .frame(maxHeight: 150)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Checkboxes
                        VStack(spacing: 12) {
                            Button(action: { agreeToTOS.toggle() }) {
                                HStack(spacing: 12) {
                                    Image(systemName: agreeToTOS ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 18))
                                        .foregroundColor(agreeToTOS ? .pink : .white.opacity(0.5))
                                    
                                    Text("I agree to the Terms of Service")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                            }
                            
                            Button(action: { agreeToPrivacy.toggle() }) {
                                HStack(spacing: 12) {
                                    Image(systemName: agreeToPrivacy ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 18))
                                        .foregroundColor(agreeToPrivacy ? .pink : .white.opacity(0.5))
                                    
                                    Text("I agree to the Privacy Policy")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Continue button
                NavigationLink(
                    destination: BirthdayVerificationView(userName: userName, email: email)
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
    
    private let tosText = """
    These Terms of Service ("Terms") govern your use of Strawbie and our services. By accessing or using Strawbie, you agree to be bound by these Terms.

    1. License Grant
    We grant you a limited, non-exclusive, non-transferable license to use Strawbie for personal, non-commercial purposes.

    2. User Responsibilities
    You agree to use Strawbie lawfully and responsibly. You are responsible for maintaining the confidentiality of your account.

    3. Intellectual Property
    All content, features, and functionality are owned by DAOmates or our content providers.

    4. Disclaimer of Warranties
    Strawbie is provided "as is" without warranties of any kind, express or implied.

    5. Limitation of Liability
    DAOmates shall not be liable for any indirect, incidental, or consequential damages.

    For the full Terms of Service, please visit our website.
    """
    
    private let privacyText = """
    Privacy Policy

    DAOmates ("we," "us," "our," or "Company") operates the Strawbie application. This page informs you of our policies regarding the collection, use, and disclosure of personal data.

    Information Collection
    We collect information you provide directly, such as your name, email, and birthday. We also collect information automatically, including device information and usage patterns.

    Use of Data
    Your data is used to:
    - Provide and maintain our service
    - Personalize your experience
    - Send service updates and promotional materials
    - Respond to your requests

    Data Security
    We implement appropriate technical and organizational measures to protect your personal data.

    Children's Privacy
    Strawbie is not intended for users under 13. We do not knowingly collect information from children under 13.

    Changes to This Privacy Policy
    We may update this Privacy Policy periodically. We will notify you of any changes.

    For the full Privacy Policy, please visit our website.
    """
}

#Preview {
    ExpandableTOSView(userName: "Bestie", email: "bestie@example.com")
}

