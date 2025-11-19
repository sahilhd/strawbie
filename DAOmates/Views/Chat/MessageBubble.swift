//
//  MessageBubble.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let avatar: Avatar
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                userMessageBubble
            } else {
                avatarMessageBubble
                Spacer()
            }
        }
    }
    
    private var userMessageBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.80, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(
                    .rect(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 6,
                        topTrailingRadius: 20
                    )
                )
            
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
                .padding(.trailing, 8)
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .trailing)
    }
    
    private var avatarMessageBubble: some View {
        HStack(alignment: .top, spacing: 10) {
            // Mini avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors(for: avatar.cryptoFocus),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                
                Image(systemName: avatarIcon(for: avatar.cryptoFocus))
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: gradientColors(for: avatar.cryptoFocus),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .clipShape(
                        .rect(
                            topLeadingRadius: 6,
                            bottomLeadingRadius: 20,
                            bottomTrailingRadius: 20,
                            topTrailingRadius: 20
                        )
                    )
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 8)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.90, alignment: .leading)
        .padding(.trailing, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
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

struct TypingIndicator: View {
    @State private var dotCount = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Mini avatar
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotCount == index ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: dotCount
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            
            Spacer()
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
        .onAppear {
            withAnimation {
                dotCount = 2
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageBubble(
            message: ChatMessage(content: "Hello! What's the latest on DeFi protocols?", isFromUser: true),
            avatar: Avatar.sampleAvatars[0]
        )
        
        MessageBubble(
            message: ChatMessage(content: "Great question! DeFi is evolving rapidly with new yield farming opportunities and innovative protocols launching every week. What specific aspect interests you most?", isFromUser: false),
            avatar: Avatar.sampleAvatars[1]
        )
        
        TypingIndicator()
    }
    .padding()
    .background(Color.black)
}
