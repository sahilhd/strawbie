//
//  VideoIntroductionView.swift
//  DAOmates
//
//  Video introduction with 3-day trial agreement
//

import SwiftUI
import AVKit

struct VideoIntroductionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var player: AVPlayer?
    @State private var hasAgreedToTrial = false
    @State private var showError = false
    
    var canContinue: Bool {
        hasAgreedToTrial
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
                
                // Video player
                ZStack {
                    Color.black
                    
                    VideoPlayer(player: player)
                        .onAppear {
                            setupPlayer()
                        }
                }
                .aspectRatio(16/9, contentMode: .fit)
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                
                // Trial info box
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.yellow)
                        
                        Text("Try Strawbie free for 3 days!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    Text("No credit card required. Cancel anytime.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Agreement checkbox
                VStack(spacing: 12) {
                    Button(action: { hasAgreedToTrial.toggle() }) {
                        HStack(spacing: 12) {
                            Image(systemName: hasAgreedToTrial ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(hasAgreedToTrial ? .pink : .white.opacity(0.5))
                            
                            Text("I agree to the 3-day free trial")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text("You'll have full access for 3 days, then choose to subscribe or cancel.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Continue button
                NavigationLink(
                    destination: NameCreationView()
                        .navigationBarBackButtonHidden(true),
                    isActive: .constant(canContinue && showError == false)
                ) {
                    Button(action: {
                        if hasAgreedToTrial {
                            // Continue to next screen
                        }
                    }) {
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
    }
    
    private func setupPlayer() {
        // Try to load the onboarding video
        let videoFileName = "Test_Flight_Onboarding_Video_V2"
        
        guard let url = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") else {
            print("❌ Video file '\(videoFileName).mp4' not found in bundle")
            print("📝 Note: Video file needs to be added to Xcode project:")
            print("   1. In Xcode, select the project")
            print("   2. Build Phases → Copy Bundle Resources")
            print("   3. Add Test_Flight_Onboarding_Video_V2.mp4")
            
            // Try alternative location or show placeholder
            showPlaceholder()
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        player = avPlayer
        
        // Auto-play
        avPlayer.play()
        
        print("✅ Video loaded and playing: \(url)")
    }
    
    private func showPlaceholder() {
        print("⚠️ Showing placeholder instead of video")
        // Video player will show black screen with controls
        // User can still proceed with onboarding
    }
}

#Preview {
    VideoIntroductionView()
}

