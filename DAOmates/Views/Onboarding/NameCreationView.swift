//
//  NameCreationView.swift
//  DAOmates
//
//  Name creation with Strawbie asking
//

import SwiftUI
import AVKit

struct NameCreationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userName = ""
    @State private var videoPlayer: AVPlayer?
    @State private var isShowingStrawbie = false
    @State private var hasPlayedAudio = false
    
    var canContinue: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                // Close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                Spacer()
                
                // Strawbie avatar with video (if available)
                if isShowingStrawbie {
                    ZStack {
                        Color.black
                        
                        if let videoURL = Bundle.main.url(forResource: "sleepmode", withExtension: "mp4") {
                            VideoPlayer(player: videoPlayer)
                                .frame(height: 280)
                                .onAppear {
                                    let playerItem = AVPlayerItem(url: videoURL)
                                    let player = AVPlayer(playerItem: playerItem)
                                    videoPlayer = player
                                    player.play()
                                }
                        } else {
                            // Fallback to placeholder
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.pink)
                        }
                    }
                    .frame(height: 280)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Speech bubble with Strawbie asking for name
                VStack(spacing: 12) {
                    Text("Hey bestie! What should I call you? 💕")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                    
                    Text("This is how I'll know you're *the* person I'm chatting with!")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .stroke(LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Name input
                VStack(spacing: 8) {
                    Text("What's your name?")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                        .submitLabel(.next)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Spacer()
                
                // Continue button
                NavigationLink(
                    destination: EmailPasswordView(userName: userName)
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
        .onAppear {
            // Show Strawbie after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isShowingStrawbie = true
                }
            }
        }
    }
}

#Preview {
    NameCreationView()
}

