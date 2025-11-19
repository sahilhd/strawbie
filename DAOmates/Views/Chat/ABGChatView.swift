//
//  ABGChatView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct ABGChatContainer: View {
    let initialPrompt: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ABGChatView(avatar: Avatar.sampleAvatars.first(where: { $0.name == "ABG" })!)
            .onAppear {
                // no-op here; actual injection is done inside ABGChatView via Notification
                if let text = initialPrompt, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    NotificationCenter.default.post(name: .abgSendInitialPrompt, object: text)
                }
            }
    }
}

extension Notification.Name {
    static let abgSendInitialPrompt = Notification.Name("abgSendInitialPrompt")
}

struct ABGChatView: View {
    let avatar: Avatar
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var speechService = SpeechService()
    @StateObject private var musicService = MusicService.shared
    @State private var messageText = ""
    @State private var isRecording = false
    @State private var showSettings = false
    @State private var showOutfitSelection = false
    @State private var selectedOutfit = Outfit.sampleOutfits[0]
    @State private var showMenu = false
    @State private var selectedMode: String = "pocket"
    @State private var showMusicPlayer = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    backgroundView
                    avatarView
                    chatUIView
                    topControlsView  // Must be last so buttons are clickable on top
                }
            }
            .navigationBarHidden(true)
            .onAppear { setupABGChat() }
            .onReceive(NotificationCenter.default.publisher(for: .abgSendInitialPrompt)) { notif in
                if let text = notif.object as? String { chatViewModel.sendUserText(text) }
            }
            .sheet(isPresented: $showSettings) { ABGSettingsView() }
            .sheet(isPresented: $showOutfitSelection) {
                OutfitSelectionView(
                    selectedOutfit: $selectedOutfit,
                    isPresented: $showOutfitSelection,
                    selectedMode: $selectedMode
                )
            }
            .photosPicker(isPresented: $showImagePicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        print("🖼️ Image selected: \(image.size)")
                    }
                }
            }
            .onChange(of: selectedMode) { oldValue, newValue in
                print("🎯 DEBUG: selectedMode changed from '\(oldValue)' to '\(newValue)'")
                PromptConfig.currentMode = newValue
                print("✅ DEBUG: PromptConfig.currentMode updated to: \(PromptConfig.currentMode)")
            }
            .onAppear {
                // Initialize the mode on appear
                PromptConfig.currentMode = selectedMode
                print("🔧 DEBUG: Initial mode set to: \(selectedMode)")
            }
        }
    }
    
    private func setupABGChat() {
        chatViewModel.avatar = avatar
    }
    
    private func sendMessage() {
        // Allow sending with image even if text is empty
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil else { return }
        
        let message = messageText.isEmpty && selectedImage != nil ? "Please analyze this image." : messageText
        var userMessage = ChatMessage(content: message, isFromUser: true)
        messageText = ""
        
        // Add image if selected
        if let image = selectedImage {
            if let base64 = ImageUtilityService.shared.imageToBase64(image) {
                userMessage = ChatMessage(content: message, isFromUser: true, imageBase64: base64)
                print("🖼️ Image attached to message, size: \(image.size)")
            }
            
            // Display image in chat
            let imageMessage = ChatMessage(content: "[📷 Image shared]", isFromUser: true, imageBase64: nil)
            chatViewModel.messages.append(imageMessage)
            selectedImage = nil
        }
        
        print("📨 Message sent: \(message)")
        
        // Check for music intent FIRST
        if let musicIntent = MusicService.detectMusicIntent(in: message) {
            print("🎵 Music intent detected: \(musicIntent.action)")
            
            // Add user message to chat
            chatViewModel.messages.append(userMessage)
            
            // Handle music and add music response (DON'T send to OpenAI)
            handleMusicIntent(musicIntent)
            showMusicPlayer = true
            print("🎵 showMusicPlayer set to true")
            print("🎵 Music-related message handled locally - NOT sent to OpenAI")
            
            // Return early so OpenAI doesn't process music requests
            return
        }
        
        print("❌ No music intent detected - sending to OpenAI")
        // Send message with potential image to OpenAI
        if let imageBase64 = userMessage.imageBase64 {
            Task {
                await chatViewModel.sendMessageWithImage(userMessage, imageBase64: imageBase64)
            }
        } else {
            chatViewModel.sendMessage(userMessage)
        }
    }
    
    private func handleMusicIntent(_ intent: MusicIntent) {
        switch intent.action {
        case .play:
            if let query = intent.query, !query.isEmpty {
                Task {
                    await musicService.searchAndPlay(query: query)
                }
                // Add music response to chat
                let musicResponses = [
                    "🎵 Now playing \(query)! Perfect vibes incoming! ✨",
                    "🎶 Just queued up \(query) for you! Let the music do its thing! 💕",
                    "✨ Playing \(query) right now! Enjoy the vibes! 🎵",
                    "🎧 \(query) is now playing! This is gonna hit! 🔥",
                    "💫 Putting on \(query) for you! Let's vibe together! 🎶"
                ]
                let response = musicResponses.randomElement() ?? "🎵 Now playing music for you!"
                let musicMessage = ChatMessage(content: response, isFromUser: false)
                chatViewModel.messages.append(musicMessage)
            } else {
                // Generic play response
                let genericResponses = [
                    "🎵 Playing some music for you! Let's vibe! ✨",
                    "🎶 Music's on! Time to relax or focus! 💕",
                    "🎧 Here's some good music for you! Enjoy! 🔥"
                ]
                let response = genericResponses.randomElement() ?? "🎵 Playing music for you!"
                let musicMessage = ChatMessage(content: response, isFromUser: false)
                chatViewModel.messages.append(musicMessage)
            }
        case .pause:
            musicService.togglePlayPause()
            let pauseMessage = ChatMessage(content: "⏸️ Music paused! Let me know when you want to continue! 💙", isFromUser: false)
            chatViewModel.messages.append(pauseMessage)
        case .next:
            musicService.nextTrack()
            let skipMessage = ChatMessage(content: "⏭️ Skipping to the next track! Hope you like this one! ✨", isFromUser: false)
            chatViewModel.messages.append(skipMessage)
        case .previous:
            musicService.previousTrack()
            let prevMessage = ChatMessage(content: "⏮️ Going back to the previous track! Enjoying it so far? 💕", isFromUser: false)
            chatViewModel.messages.append(prevMessage)
        }
    }
    
    // MARK: - Computed Properties for Body Refactoring
    
    private var chatUIView: some View {
        VStack(spacing: 0) {
            // Scrollable Chat Messages
            if !chatViewModel.messages.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(chatViewModel.messages, id: \.id) { message in
                        HStack(alignment: .bottom, spacing: 0) {
                            if message.isFromUser {
                                Spacer(minLength: 40)
                                Text(message.content)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 14)
                                    .background(Capsule().fill(Color.black.opacity(0.75)).shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4))
                                    .overlay(Capsule().stroke(LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5))
                                    .multilineTextAlignment(.trailing)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: 260)
                            } else {
                                Text(message.content)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.white)
                                    .lineSpacing(5)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white.opacity(0.15))
                                            .background(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1.5
                                                    )
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: 280, alignment: .leading)
                                Spacer(minLength: 40)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    if chatViewModel.isProcessing {
                        HStack {
                            HStack(spacing: 8) {
                                Text("Strawbie is typing")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { _ in Circle().fill(Color.white).frame(width: 4, height: 4).opacity(0.7) }
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .padding(.bottom, 12)
                .frame(maxHeight: .infinity)
            } else {
                Spacer()
            }
            
            // Mode Selection Buttons - Always accessible, even with music playing
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    // Mode buttons - change mode without sending message
                    Button(action: {
                        print("🔘 DEBUG: 'Get ready with me' mode button tapped")
                        selectedMode = "pocket"
                    }) {
                        Text("Get ready with me")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        print("🔘 DEBUG: 'Study' mode button tapped")
                        selectedMode = "study"
                    }) {
                        Text("Study")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        print("🔘 DEBUG: 'Vibe' mode button tapped")
                        selectedMode = "chill"
                    }) {
                        Text("Vibe")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        print("🔘 DEBUG: 'I'm sleepy' mode button tapped")
                        selectedMode = "sleep"
                    }) {
                        Text("I'm sleepy")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
            
            // Music Player - Only shown when playing, doesn't block buttons
            if showMusicPlayer || musicService.currentTrack != nil {
                MusicPlayerWidget(musicService: musicService)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if let image = selectedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .cornerRadius(8)
                    Button(action: { selectedImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            
            HStack(spacing: 12) {
                Menu {
                    Button(action: { showImagePicker = true }) { Label("Choose Photo", systemImage: "photo") }
                    Button(action: { print("📷 Camera tapped") }) { Label("Take Photo", systemImage: "camera") }
                } label: {
                    Image(systemName: "photo")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(selectedImage != nil ? .pink : .white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                TextField("Ask me anything", text: $messageText)
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .onSubmit { sendMessage() }
                
                Button(action: { sendMessage() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane.fill")
                            .font(.callout)
                        Text("Send")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.white)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var backgroundView: some View {
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.15),
                            Color.purple.opacity(0.25),
                            Color.blue.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(.all)
    }
    
    private var avatarView: some View {
                    ABGAvatarDisplay(
                        isAnimating: chatViewModel.isProcessing,
                        messages: chatViewModel.messages,
                        selectedOutfit: selectedOutfit
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.all)
    }
                    
    private var topControlsView: some View {
                    VStack {
                        HStack(alignment: .top) {
                            // Left vertical button stack
                            VStack(spacing: 14) {
                                // Hamburger Menu
                                Button(action: { showMenu.toggle() }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .overlay(
                                                    Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                                )
                                        )
                                }
                                
                                // New Chat Button
                                Button(action: {
                                    withAnimation {
                                        chatViewModel.clearChat()
                                    }
                                }) {
                                    Image(systemName: "plus.message")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .overlay(
                                                    Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                            .padding(.leading, 16)
                            
                            Spacer()
                            
                            // Right vertical button stack
                            VStack(spacing: 14) {
                    Button(action: { showSettings = true }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                            )
                                                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                                }
                    Button(action: { /* TODO: effects */ }) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                                        )
                                }
                    Button(action: { showOutfitSelection = true }) {
                                    Image(systemName: "hanger")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.5))
                                                .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                                        )
                                }
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.top, 28)
                        Spacer()
                    }
    }
}

// MARK: - Suggested Prompt Chip
struct SuggestedPromptChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                                    .background(
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ABGChatContainer(initialPrompt: "Hello ABG!")
}
