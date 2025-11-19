//
//  TermsOfServiceView.swift
//  DAOmates
//
//  Terms of Service
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Terms of Service")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        
                        Text("Last Updated: October 9, 2025")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Group {
                            SectionTitle("1. Acceptance of Terms")
                            SectionBody("By accessing and using DAOmates, you accept and agree to be bound by the terms and provision of this agreement.")
                            
                            SectionTitle("2. Use of Service")
                            SectionBody("DAOmates provides AI-powered chat companions focused on cryptocurrency and blockchain topics. The service is intended for informational and educational purposes only.")
                            
                            SectionTitle("3. Not Financial Advice")
                            SectionBody("The information provided through DAOmates is not financial, investment, or legal advice. Always conduct your own research (DYOR) and consult with qualified professionals before making any investment decisions.")
                            
                            SectionTitle("4. User Accounts")
                            SectionBody("You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.")
                            
                            SectionTitle("5. Prohibited Uses")
                            SectionBody("You may not use DAOmates for any illegal purposes, to violate any laws, or to harm others. We reserve the right to terminate accounts that violate these terms.")
                            
                            SectionTitle("6. Intellectual Property")
                            SectionBody("All content, features, and functionality of DAOmates are owned by us and are protected by international copyright, trademark, and other intellectual property laws.")
                            
                            SectionTitle("7. Privacy")
                            SectionBody("Your use of DAOmates is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.")
                            
                            SectionTitle("8. Limitation of Liability")
                            SectionBody("DAOmates is provided \"as is\" without warranties of any kind. We shall not be liable for any indirect, incidental, special, consequential, or punitive damages.")
                            
                            SectionTitle("9. Changes to Terms")
                            SectionBody("We reserve the right to modify these terms at any time. We will notify users of any material changes via email or through the app.")
                            
                            SectionTitle("10. Contact")
                            SectionBody("For questions about these Terms of Service, please contact us at support@daomates.app")
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        
                        Text("Last Updated: October 9, 2025")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Group {
                            SectionTitle("1. Information We Collect")
                            SectionBody("We collect information you provide directly, such as your username, email address, and optional wallet address. We also collect usage data to improve our service.")
                            
                            SectionTitle("2. How We Use Your Information")
                            SectionBody("We use your information to provide and improve our service, communicate with you, and ensure account security.")
                            
                            SectionTitle("3. Data Storage and Security")
                            SectionBody("Your data is stored securely using industry-standard encryption. We implement appropriate security measures to protect your personal information.")
                            
                            SectionTitle("4. Chat History")
                            SectionBody("Your chat conversations are stored locally on your device and in our secure cloud storage. We use this data to provide personalized experiences and improve our AI models.")
                            
                            SectionTitle("5. Third-Party Services")
                            SectionBody("We use third-party services like OpenAI for AI functionality. These services have their own privacy policies governing the use of your information.")
                            
                            SectionTitle("6. Data Sharing")
                            SectionBody("We do not sell your personal information. We may share data with service providers who assist in operating our service, subject to confidentiality agreements.")
                            
                            SectionTitle("7. Your Rights")
                            SectionBody("You have the right to access, correct, or delete your personal information. You can manage your data through your account settings or by contacting us.")
                            
                            SectionTitle("8. Biometric Data")
                            SectionBody("If you enable Face ID or Touch ID, biometric authentication is handled entirely by your device. We do not collect or store biometric data.")
                            
                            SectionTitle("9. Children's Privacy")
                            SectionBody("Our service is not intended for users under 18 years of age. We do not knowingly collect information from children.")
                            
                            SectionTitle("10. Changes to Privacy Policy")
                            SectionBody("We may update this privacy policy from time to time. We will notify you of any material changes by posting the new policy in the app.")
                            
                            SectionTitle("11. Contact Us")
                            SectionBody("If you have questions about this Privacy Policy, please contact us at privacy@daomates.app")
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Helper Views
private struct SectionTitle: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.cyan)
            .padding(.top, 8)
    }
}

private struct SectionBody: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.white.opacity(0.8))
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    TermsOfServiceView()
}

#Preview("Privacy") {
    PrivacyPolicyView()
}

