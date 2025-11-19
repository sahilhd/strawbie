//
//  ABGVideoAvatarView.swift
//  DAOmates
//
//  Created by Sahil Handa on 2025-09-03.
//

/*
 🎯 VIDEO SETTINGS GUIDE:
 
 To adjust video size and position, modify these constants in the ABGVideoAvatarView struct:
 
 • videoScale: Controls video size
   - 1.0 = normal size
   - 1.5 = 50% larger (current setting)
   - 2.0 = double size
   - 0.8 = 20% smaller
 
 • videoOffsetX: Horizontal position
   - 0 = centered (current)
   - -50 = moved left
   - 50 = moved right
 
 • videoOffsetY: Vertical position
   - -50 = moved up (current setting)
   - 0 = centered
   - 50 = moved down
 
 • aspectRatioMode: How video fills screen
   - .fill = crop video to fill entire screen (current)
   - .fit = show entire video with possible black bars
*/

import SwiftUI
import AVFoundation
import AVKit

struct ABGVideoAvatarView: View {
    let avatar: Avatar
    let isAnimating: Bool
    let messages: [ChatMessage]
    let selectedOutfit: Outfit
    @State private var showVideoPlayer = false
    @State private var isVideoMode = true
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var showOutfitSelection = false
    
   // 🎯 VIDEO SETTINGS - Fills entire screen without black borders
    private let videoScale: CGFloat = 1.2        // Slightly increased to ensure full screen coverage
    private let videoOffsetX: CGFloat = -210        // Slight left offset for better framing
    private let videoOffsetY: CGFloat = 0        // No offset  
    private let aspectRatioMode: ContentMode = .fill  // Fill entire screen without black borders

    // 🎯 CUSTOM FRAME SETTINGS - Standard frame settings
    private let videoWidth: CGFloat? = nil       // Use natural width
    private let videoHeight: CGFloat? = nil      // Use natural height
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                    if isVideoMode {
        // Full Screen Immersive Video Background - Maximum Coverage
        VideoAvatarPlayer(
            isAnimating: isAnimating,
            messages: messages,
            videoScale: videoScale,
            videoOffsetX: videoOffsetX,
            videoOffsetY: videoOffsetY,
            aspectRatioMode: aspectRatioMode,
            selectedOutfit: selectedOutfit
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(contentMode: .fill)
        .clipped()
        .ignoresSafeArea(.all) // Cover entire screen including safe areas
                } else {
                    // Photo Mode with proper image loading
                    PhotoAvatarView(
                        avatar: avatar,
                        isAnimating: isAnimating,
                        geometry: geometry
                    ) {
                        // Tap to switch to video mode
                        withAnimation(.spring()) {
                            isVideoMode = true
                        }
                    }
                }
                
                // Minimal overlay: none here. All controls live in ABGChatView.
                
            }
        }
        // No sheets here. Outfit selection is handled by ABGChatView only.
    }
    
    private func toggleVideoMode() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isVideoMode.toggle()
        }
    }
    
}

// New Photo Avatar View with proper image loading
struct PhotoAvatarView: View {
    let avatar: Avatar
    let isAnimating: Bool
    let geometry: GeometryProxy
    let onTap: () -> Void
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.3),
                    Color.purple.opacity(0.3),
                    Color.blue.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Main avatar
            Button(action: onTap) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.pink.opacity(0.4),
                                    Color.purple.opacity(0.2),
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
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: pulseScale
                        )
                    
                    // Avatar image with proper loading - moved higher
                    Group {
                        // Try to load the ABG image
                        if let uiImage = UIImage(named: avatar.imageName) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 300)
                                .clipShape(Circle())
                        } else if let uiImage = UIImage(named: "abg_avatar") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 300)
                                .clipShape(Circle())
                        } else {
                            // Fallback with beautiful styling
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 300, height: 300)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text("ABG")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 4)
                            .frame(width: 300, height: 300)
                    )
                    .shadow(color: .pink.opacity(0.7), radius: 15, x: 0, y: 8)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                    .offset(y: -40) // Move avatar higher up on screen
                    
                    // Clean avatar without emoji circle
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            pulseScale = 1.1
        }
    }
}

struct VideoAvatarPlayer: View {
    let isAnimating: Bool
    let messages: [ChatMessage]
    let videoScale: CGFloat
    let videoOffsetX: CGFloat
    let videoOffsetY: CGFloat
    let aspectRatioMode: ContentMode
    let selectedOutfit: Outfit
    @State private var player: AVPlayer?
    @State private var playerLooper: AVPlayerLooper?
    @State private var queuePlayer: AVQueuePlayer?
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Full Screen Video Player - Consistent sizing for all outfits
            if let player = queuePlayer {
                VideoPlayer(player: player)
                    .disabled(true) // Disable controls
                    .scaleEffect(pulseScale * videoScale) // Uniform scaling
                    .offset(x: videoOffsetX, y: videoOffsetY) // Centered positioning
                    .animation(
                        isAnimating ? 
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                        .easeOut(duration: 0.3),
                        value: pulseScale
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: aspectRatioMode) // Respect video's natural aspect ratio
                    .clipped()
                    .ignoresSafeArea(.all) // Cover entire screen including safe areas
            } else {
                // Loading placeholder with immersive styling
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.pink.opacity(0.4),
                                Color.purple.opacity(0.4),
                                Color.blue.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Loading ABG...")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    )
                    .ignoresSafeArea(.all)
            }
            
            // Subtle glow overlay when speaking - no borders
            if isAnimating {
                Rectangle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.pink.opacity(glowOpacity * 0.3),
                                Color.purple.opacity(glowOpacity * 0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 100,
                            endRadius: 400
                        )
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: glowOpacity
                    )
                    .allowsHitTesting(false)
                    .ignoresSafeArea(.all)
            }
            
            // Interaction overlay
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    // Optional: Add tap interactions here
                }
                .ignoresSafeArea(.all)
        }
        .onAppear {
            setupVideoPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
        .onChange(of: selectedOutfit.id) { _, _ in
            setupVideoPlayer()
        }
        .onChange(of: isAnimating) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                pulseScale = newValue ? 1.02 : 1.0
                glowOpacity = newValue ? 1.0 : 0.0
            }
        }
    }
    
    private func setupVideoPlayer() {
        // Clean up previous player
        cleanupPlayer()
        
        // Configure audio session for video playback
        setupAudioSession()
        
        // Get video file name from selected outfit
        let videoFileName = selectedOutfit.videoFileName
        let fileNameWithoutExtension = videoFileName.replacingOccurrences(of: ".mov", with: "").replacingOccurrences(of: ".mp4", with: "")
        let fileExtension = videoFileName.contains(".mp4") ? "mp4" : "mov"
        
        // Try to find the video file
        var videoURL: URL?
        
        // First try in the main bundle
        videoURL = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: fileExtension)
        
        // If not found in bundle, try in the outfits folder
        if videoURL == nil {
            if let outfitsPath = Bundle.main.path(forResource: "outfits", ofType: nil) {
                let outfitVideoPath = outfitsPath + "/" + videoFileName
                videoURL = URL(fileURLWithPath: outfitVideoPath)
                
                // Check if file exists
                if !FileManager.default.fileExists(atPath: outfitVideoPath) {
                    videoURL = nil
                }
            }
        }
        
        guard let videoURL = videoURL else {
            print("❌ Video file not found: \(videoFileName)")
            return
        }
        
        print("✅ Found video file: \(videoURL)")
        
        let playerItem = AVPlayerItem(url: videoURL)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Create looper for seamless loop
        if let queuePlayer = queuePlayer {
            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
            
            // Configure player - UNMUTE for audio playback
            queuePlayer.isMuted = false // Enable audio
            queuePlayer.volume = 1.0 // Set volume to maximum
            queuePlayer.play()
            
            print("✅ Video player setup complete for outfit: \(selectedOutfit.name)")
            print("🔊 Audio enabled, volume: \(queuePlayer.volume)")
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure for playback with speaker output and mix with other audio
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true)
            
            print("✅ Audio session configured for video playback")
            print("🔊 Category: \(audioSession.category)")
            print("🔊 Mode: \(audioSession.mode)")
            print("🔊 Output route: \(audioSession.currentRoute.outputs.map { $0.portName })")
            
        } catch {
            print("❌ Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func cleanupPlayer() {
        queuePlayer?.pause()
        queuePlayer = nil
        playerLooper = nil
    }
}

// Enhanced ABG Avatar Display that integrates video
struct ABGAvatarDisplay: View {
    let isAnimating: Bool
    let messages: [ChatMessage]
    let selectedOutfit: Outfit
    
    var body: some View {
        ABGVideoAvatarView(
            avatar: Avatar.sampleAvatars.first(where: { $0.name == "ABG" })!,
            isAnimating: isAnimating,
            messages: messages,
            selectedOutfit: selectedOutfit
        )
    }
}

#Preview {
    ABGVideoAvatarView(
        avatar: Avatar.sampleAvatars.first(where: { $0.name == "ABG" })!,
        isAnimating: true,
        messages: [],
        selectedOutfit: Outfit.sampleOutfits[0]
    )
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.05, blue: 0.15),
                Color(red: 0.2, green: 0.1, blue: 0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

