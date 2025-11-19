//
//  NotificationPreferenceView.swift
//  DAOmates
//
//  Email and notification preferences slider
//

import SwiftUI

struct NotificationPreferenceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let userName: String
    let email: String
    
    @State private var emailNotifications: Double = 0.7
    @State private var appNotifications: Double = 0.7
    @State private var isCreatingAccount = false
    
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
                    Text("Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                // Progress indicator
                VStack(spacing: 6) {
                    Text("Step 5 of 5")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.pink)
                                .frame(width: geo.size.width * 1.0)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Intro text
                        VStack(spacing: 8) {
                            Text("Stay Connected with Strawbie")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Customize how you want to hear from us")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        
                        // Email notifications slider
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.cyan)
                                    
                                    Text("Email Notifications")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Text(getNotificationLevel(emailNotifications))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.pink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.pink.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: $emailNotifications, in: 0...1, step: 0.25)
                                .tint(.pink)
                            
                            HStack(spacing: 0) {
                                Text("Never")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Spacer()
                                
                                Text("Always")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // App notifications slider
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.cyan)
                                    
                                    Text("App Notifications")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Text(getNotificationLevel(appNotifications))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.pink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.pink.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            
                            Slider(value: $appNotifications, in: 0...1, step: 0.25)
                                .tint(.pink)
                            
                            HStack(spacing: 0) {
                                Text("Never")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Spacer()
                                
                                Text("Always")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Info box
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.cyan)
                                
                                Text("You can change these settings anytime in your preferences")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cyan.opacity(0.1))
                                .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
                
                // Get started button
                Button(action: {
                    isCreatingAccount = true
                    // In a real app, you'd create the account here
                    // For now, we'll just move to the chat
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        authViewModel.isAuthenticated = true
                        authViewModel.showOnboarding = false
                    }
                }) {
                    if isCreatingAccount {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.black)
                            
                            Text("Creating Account...")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink)
                        )
                    } else {
                        Text("Start Chatting with Strawbie! 🍓")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.pink)
                            )
                    }
                }
                .disabled(isCreatingAccount)
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getNotificationLevel(_ value: Double) -> String {
        switch value {
        case 0:
            return "Never"
        case 0.25:
            return "Minimal"
        case 0.5:
            return "Moderate"
        case 0.75:
            return "Frequent"
        case 1.0:
            return "Always"
        default:
            return "Custom"
        }
    }
}

#Preview {
    NotificationPreferenceView(userName: "Bestie", email: "bestie@example.com")
        .environmentObject(AuthViewModel())
}

