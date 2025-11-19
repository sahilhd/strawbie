//
//  ABGHomeView.swift
//  DAOmates
//
//  Premium ABG companion home screen
//

import SwiftUI

struct ABGHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    @State private var showChat = false
    @State private var pendingPrompt: String? = nil
    @State private var greeting = ""
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.1),
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(authViewModel.currentUser?.username ?? "Bestie")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
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
                                        .frame(width: 44, height: 44)
                                    
                                    Text(user.username.prefix(1).uppercased())
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // ABG Character Card
                    ABGCharacterCard(showChat: $showChat)
                        .padding(.horizontal, 24)
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .opacity(isAnimating ? 1.0 : 0)
                    
                    // Quick Actions
                    VStack(spacing: 12) {
                        Text("What's on your mind?")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                QuickActionCard(
                                    icon: "bag.fill",
                                    title: "Shopping Tips",
                                    gradient: [.pink, .orange],
                                    action: { startConversation(with: "Can you give me shopping tips that fit a trendy ABG vibe?") }
                                )
                                
                                QuickActionCard(
                                    icon: "bitcoinsign.circle.fill",
                                    title: "Crypto 101",
                                    gradient: [.cyan, .blue],
                                    action: { startConversation(with: "Explain crypto to me like I'm your stylish bestie.") }
                                )
                                
                                QuickActionCard(
                                    icon: "paintpalette.fill",
                                    title: "Beauty & Style",
                                    gradient: [.purple, .pink],
                                    action: { startConversation(with: "What's trending in beauty and style right now?") }
                                )
                                
                                QuickActionCard(
                                    icon: "photo.artframe",
                                    title: "NFTs",
                                    gradient: [.green, .cyan],
                                    action: { startConversation(with: "What NFTs should I look at this week?") }
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Recent Chats (if any)
                    if let chatHistory = authViewModel.currentUser?.chatHistory, !chatHistory.isEmpty {
                        VStack(spacing: 16) {
                            Text("Continue Chatting")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 30)
                            
                            ForEach(chatHistory.prefix(3)) { session in
                                RecentChatCard(session: session) {
                                    showChat = true
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Floating Chat Button
            VStack {
                Spacer()
                
                Button(action: { showChat = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "message.fill")
                            .font(.title3)
                        
                        Text("Chat with ABG")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.white, .pink.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .pink.opacity(0.5), radius: 20, x: 0, y: 10)
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $showChat) {
            ABGChatContainer(initialPrompt: pendingPrompt)
        }
        .onAppear {
            updateGreeting()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            greeting = "Good Morning,"
        case 12..<17:
            greeting = "Good Afternoon,"
        default:
            greeting = "Good Evening,"
        }
    }
    
    private func startConversation(with message: String) {
        // Store the initial message and show chat
        showChat = true
        // The message will be auto-sent in the chat view
    }
}

// MARK: - ABG Character Card
struct ABGCharacterCard: View {
    @Binding var showChat: Bool
    @State private var isHovering = false
    
    var body: some View {
        Button(action: { showChat = true }) {
            VStack(spacing: 0) {
                // ABG Image
                ZStack(alignment: .bottomTrailing) {
                    if let uiImage = UIImage(named: "abg_avatar") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 320)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 320)
                    }
                    
                    // Status Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("Online")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .padding(16)
                }
                
                // Info Section
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ABG")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your fashion-forward crypto bestie")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.pink)
                    }
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Tag(text: "Fashion", icon: "sparkles")
                            Tag(text: "Crypto", icon: "bitcoinsign.circle")
                            Tag(text: "NFTs", icon: "photo.artframe")
                            Tag(text: "Shopping", icon: "bag")
                        }
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.05))
            }
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .scaleEffect(isHovering ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.3)) {
                        isHovering = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3)) {
                        isHovering = false
                    }
                }
        )
    }
}

// MARK: - Tag
struct Tag: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Recent Chat Card
struct RecentChatCard: View {
    let session: ChatSession
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("💬")
                            .font(.title3)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.messages.last?.content.prefix(50) ?? "Continue chat")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(timeAgo(from: session.lastMessageAt))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60))m ago"
        } else if seconds < 86400 {
            return "\(Int(seconds / 3600))h ago"
        } else {
            return "\(Int(seconds / 86400))d ago"
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    ABGHomeView()
        .environmentObject(AuthViewModel())
}

