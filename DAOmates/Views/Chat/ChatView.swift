//
//  ChatView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI
import AVKit

struct ChatView: View {
    let avatar: Avatar
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var isRecording = false
    @State private var showVideoPlayer = false
    @State private var currentVideoURL: URL?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.05, blue: 0.18),
                    Color(red: 0.05, green: 0.08, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Avatar Info
                ChatHeaderView(avatar: avatar) {
                    dismiss()
                }
                
                // Avatar Visual Component
                Group {
                    if avatar.name == "ABG" {
                        ABGAvatarView(
                            avatar: avatar,
                            isAnimating: chatViewModel.isProcessing
                        ) {
                            // Handle ABG avatar tap - could play video or show special animation
                            if let videoURL = Bundle.main.url(forResource: avatar.videoName ?? "abg_response", withExtension: "mp4") {
                                currentVideoURL = videoURL
                                showVideoPlayer = true
                            }
                        }
                    } else {
                        AvatarVisualView(
                            avatar: avatar,
                            isAnimating: chatViewModel.isProcessing
                        ) { videoURL in
                            currentVideoURL = videoURL
                            showVideoPlayer = true
                        }
                    }
                }
                .frame(height: 300)
                
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatViewModel.messages) { message in
                                MessageBubble(message: message, avatar: avatar)
                                    .id(message.id)
                            }
                            
                            if chatViewModel.isProcessing {
                                TypingIndicator()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }
                    .onChange(of: chatViewModel.messages.count) {
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message Input
                MessageInputView(
                    messageText: $messageText,
                    isRecording: $isRecording,
                    onSendMessage: {
                        sendMessage()
                    },
                    onStartRecording: {
                        startVoiceRecording()
                    },
                    onStopRecording: {
                        stopVoiceRecording()
                    }
                )
            }
        }
        .sheet(isPresented: $showVideoPlayer) {
            if let videoURL = currentVideoURL {
                VideoPlayerView(videoURL: videoURL)
            }
        }
        .onAppear {
            chatViewModel.avatar = avatar
            // Add welcome message
            if chatViewModel.messages.isEmpty {
                let welcomeMessage = ChatMessage(
                    content: "Hey there! I'm \(avatar.name). \(avatar.description). What would you like to discuss about \(avatar.cryptoFocus.rawValue.lowercased())?",
                    isFromUser: false
                )
                chatViewModel.messages.append(welcomeMessage)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(content: messageText, isFromUser: true)
        chatViewModel.sendMessage(userMessage)
        messageText = ""
    }
    
    private func startVoiceRecording() {
        isRecording = true
        // TODO: Implement speech-to-text
    }
    
    private func stopVoiceRecording() {
        isRecording = false
        // TODO: Process recorded audio and convert to text
    }
}

struct ChatHeaderView: View {
    let avatar: Avatar
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.cyan)
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors(for: avatar.cryptoFocus),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: avatarIcon(for: avatar.cryptoFocus))
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(avatar.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(avatar.specialization)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.3))
    }
    
    private func gradientColors(for focus: Avatar.CryptoFocus) -> [Color] {
        switch focus {
        case .defi: return [.green, .cyan]
        case .nft: return [.purple, .pink]
        case .trading: return [.orange, .red]
        case .dao: return [.blue, .purple]
        case .blockchain: return [.yellow, .orange]
        case .metaverse: return [.pink, .purple]
        }
    }
    
    private func avatarIcon(for focus: Avatar.CryptoFocus) -> String {
        switch focus {
        case .defi: return "chart.line.uptrend.xyaxis"
        case .nft: return "photo.artframe"
        case .trading: return "chart.bar.fill"
        case .dao: return "person.3.sequence.fill"
        case .blockchain: return "link"
        case .metaverse: return "visionpro"
        }
    }
}

struct AvatarVisualView: View {
    let avatar: Avatar
    let isAnimating: Bool
    let onVideoTap: (URL) -> Void
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Background glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            gradientColors(for: avatar.cryptoFocus)[0].opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(pulseScale)
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: pulseScale
                )
            
            // Main avatar circle
            Button(action: {
                // Simulate video response
                if let videoURL = Bundle.main.url(forResource: avatar.videoName ?? "default_response", withExtension: "mp4") {
                    onVideoTap(videoURL)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors(for: avatar.cryptoFocus),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    // Avatar icon
                    Image(systemName: avatarIcon(for: avatar.cryptoFocus))
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Speaking indicator
                    if isAnimating {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                .frame(width: 200 + CGFloat(index * 20))
                                .scaleEffect(pulseScale)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: pulseScale
                                )
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Crypto symbols floating around
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * 45
                let symbols = ["₿", "Ξ", "◊", "⟐"]
                
                Text(symbols[index % symbols.count])
                    .font(.title2)
                    .foregroundColor(gradientColors(for: avatar.cryptoFocus)[0].opacity(0.4))
                    .offset(
                        x: cos(Angle.degrees(angle + rotationAngle).radians) * 120,
                        y: sin(Angle.degrees(angle + rotationAngle).radians) * 120
                    )
            }
        }
        .onAppear {
            pulseScale = 1.1
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
    
    private func gradientColors(for focus: Avatar.CryptoFocus) -> [Color] {
        switch focus {
        case .defi: return [.green, .cyan]
        case .nft: return [.purple, .pink]
        case .trading: return [.orange, .red]
        case .dao: return [.blue, .purple]
        case .blockchain: return [.yellow, .orange]
        case .metaverse: return [.pink, .purple]
        }
    }
    
    private func avatarIcon(for focus: Avatar.CryptoFocus) -> String {
        switch focus {
        case .defi: return "chart.line.uptrend.xyaxis"
        case .nft: return "photo.artframe"
        case .trading: return "chart.bar.fill"
        case .dao: return "person.3.sequence.fill"
        case .blockchain: return "link"
        case .metaverse: return "visionpro"
        }
    }
}

#Preview {
    ChatView(avatar: Avatar.sampleAvatars[0])
}
