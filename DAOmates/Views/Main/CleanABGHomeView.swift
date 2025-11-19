//
//  CleanABGHomeView.swift
//  DAOmates
//
//  Minimal, clean ABG home screen
//

import SwiftUI

struct CleanABGHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    @State private var showChat = false
    @State private var pendingPrompt: String? = nil
    
    var body: some View {
        ZStack {
            // Clean dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Minimal Header
                HStack {
                    Text("Strawbie")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Profile Button
                    Button(action: { showProfile = true }) {
                        if let user = authViewModel.currentUser {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 36, height: 36)
                                
                                Text(user.username.prefix(1).uppercased())
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Main Content - Centered
                VStack(spacing: 24) {
                    // Strawbie Avatar
                    Image("pocketmode")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.pink.opacity(0.6), .purple.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .pink.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    // Name and Status
                    VStack(spacing: 8) {
                        Text("Strawbie")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text("Online")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Simple Description
                    Text("Let's vibe!")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Single CTA Button
                Button(action: { 
                    pendingPrompt = nil
                    showChat = true 
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "message.fill")
                            .font(.title3)
                        
                        Text("Start Chatting")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.white, .pink.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .white.opacity(0.2), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $showChat) {
            ABGChatContainer(initialPrompt: pendingPrompt)
        }
    }
}

#Preview {
    CleanABGHomeView()
        .environmentObject(AuthViewModel())
}

