//
//  FullScreenVideoIntroView.swift
//  DAOmates
//
//  Full-screen onboarding video (like mode video)
//

import SwiftUI
import AVKit

struct FullScreenVideoIntroView: View {
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var showOnboardingForms = false
    @State private var videoEnded = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Full screen video (fills entire screen)
            if let player = player {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.black
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            ProgressView()
                                .tint(.white)
                            Text("Loading video...")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                    )
            }
            
            // Top-left close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .zIndex(10)
            
            // Bottom-right skip button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showOnboardingForms = true }) {
                        Text("Skip")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(10)
        }
        .onAppear {
            setupPlayer()
        }
        .sheet(isPresented: $showOnboardingForms) {
            OnboardingFormsContainerView()
        }
        .navigationBarHidden(true)
    }
    
    private func setupPlayer() {
        // Configure audio session for video playback
        setupAudioSession()
        
        guard let url = Bundle.main.url(forResource: "Test_Flight_Onboarding_Video_V2", withExtension: "mp4") else {
            print("❌ Onboarding video not found in bundle")
            print("📝 Make sure Test_Flight_Onboarding_Video_V2.mp4 is in Build Phases → Copy Bundle Resources")
            return
        }
        
        print("✅ Found onboarding video at: \(url)")
        
        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        
        // Enable audio
        avPlayer.isMuted = false
        avPlayer.volume = 1.0
        
        // Set up player to play
        DispatchQueue.main.async {
            self.player = avPlayer
            print("📹 Video player created and assigned")
            print("🔊 Audio enabled, volume: \(avPlayer.volume)")
            
            // Start playing
            avPlayer.play()
            print("▶️ Playing onboarding video")
        }
        
        // Listen for video end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            print("✅ Onboarding video finished playing")
            self.videoEnded = true
            self.showOnboardingForms = true
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure for playback with speaker output
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            print("✅ Audio session configured for onboarding video")
            print("🔊 Category: \(audioSession.category)")
            print("🔊 Mode: \(audioSession.mode)")
            
        } catch {
            print("❌ Failed to setup audio session: \(error.localizedDescription)")
        }
    }
}

#Preview {
    FullScreenVideoIntroView()
}

